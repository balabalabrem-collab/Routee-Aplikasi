<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Exception;

class PaymentController extends Controller
{
    public function __construct()
    {
        // Initialize Midtrans configuration
        \Midtrans\Config::$serverKey = env('MIDTRANS_SERVER_KEY', '');
        \Midtrans\Config::$isProduction = filter_var(env('MIDTRANS_IS_PRODUCTION', false), FILTER_VALIDATE_BOOLEAN);
        \Midtrans\Config::$isSanitized = true;
        \Midtrans\Config::$is3ds = true;
    }

    /**
     * Add CORS headers to every response
     */
    private function corsResponse($data, $status = 200)
    {
        return response()->json($data, $status)->withHeaders([
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With',
        ]);
    }

    /**
     * Handle CORS preflight OPTIONS requests
     */
    public function handleOptions()
    {
        return response('', 200)->withHeaders([
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With',
        ]);
    }

    /**
     * Ensure payments table exists (SQLite compatible)
     */
    private function ensurePaymentsTable()
    {
        if (!Schema::hasTable('payments')) {
            Schema::create('payments', function ($table) {
                $table->id();
                $table->string('order_id')->unique();
                $table->string('renter_name');
                $table->string('renter_phone');
                $table->string('vehicle_type');
                $table->string('driver_name')->nullable();
                $table->string('payment_method')->nullable();
                $table->integer('amount');
                $table->string('snap_token')->nullable();
                $table->string('redirect_url')->nullable();
                $table->string('transaction_status')->default('pending');
                $table->string('payment_type')->nullable();
                $table->string('fraud_status')->nullable();
                $table->timestamps();
            });
        }
    }

    /**
     * Create Midtrans Snap Token and save transaction record
     */
    public function createSnapToken(Request $request)
    {
        // Handle preflight
        if ($request->isMethod('OPTIONS')) {
            return $this->handleOptions();
        }

        try {
            $validated = $request->validate([
                'amount'       => 'required|numeric|min:1000',
                'renter_name'  => 'required|string',
                'renter_phone' => 'required|string',
                'vehicle_type' => 'required|string',
                'driver_name'  => 'nullable|string',
                'payment_method' => 'nullable|string',
            ]);

            // Validate server key is configured
            $serverKey = env('MIDTRANS_SERVER_KEY', '');
            if (empty($serverKey)) {
                return $this->corsResponse([
                    'status'  => 'error',
                    'message' => 'Midtrans Server Key belum dikonfigurasi di server.',
                ], 500);
            }

            $orderId = 'ROUTEE-' . time() . '-' . rand(100, 999);
            $amount  = (int) $validated['amount'];

            // Transaction Details
            $transaction_details = [
                'order_id'     => $orderId,
                'gross_amount' => $amount,
            ];

            // Item Details
            $item_details = [
                [
                    'id'       => strtolower(str_replace(' ', '-', $validated['vehicle_type'])),
                    'price'    => $amount,
                    'quantity' => 1,
                    'name'     => 'Routee - Sewa ' . $validated['vehicle_type']
                                  . ($validated['driver_name'] ? ' (' . $validated['driver_name'] . ')' : ''),
                ]
            ];

            // Customer Details
            $customer_details = [
                'first_name' => $validated['renter_name'],
                'phone'      => $validated['renter_phone'],
            ];

            // Enabled Payment Methods
            $enabled_payments = [
                'credit_card', 'bca_va', 'bni_va', 'bri_va',
                'mandiri_bill', 'permata_va', 'other_va',
                'gopay', 'shopeepay', 'dana', 'ovo',
                'alfamart', 'indomaret',
            ];

            $payload = [
                'transaction_details' => $transaction_details,
                'item_details'        => $item_details,
                'customer_details'    => $customer_details,
                'enabled_payments'    => $enabled_payments,
                'callbacks'           => [
                    'finish' => env('APP_URL', 'http://localhost') . '/payment/finish',
                ],
            ];

            // Get Snap Token and URL from Midtrans
            $snapToken   = \Midtrans\Snap::getSnapToken($payload);
            $redirectUrl = \Midtrans\Snap::getSnapUrl($payload);

            // Save transaction to DB
            try {
                $this->ensurePaymentsTable();
                DB::table('payments')->insert([
                    'order_id'           => $orderId,
                    'renter_name'        => $validated['renter_name'],
                    'renter_phone'       => $validated['renter_phone'],
                    'vehicle_type'       => $validated['vehicle_type'],
                    'driver_name'        => $validated['driver_name'] ?? null,
                    'payment_method'     => $validated['payment_method'] ?? null,
                    'amount'             => $amount,
                    'snap_token'         => $snapToken,
                    'redirect_url'       => $redirectUrl,
                    'transaction_status' => 'pending',
                    'created_at'         => now(),
                    'updated_at'         => now(),
                ]);
            } catch (\Exception $dbErr) {
                Log::warning('Failed to save payment to DB (non-fatal): ' . $dbErr->getMessage());
            }

            Log::info("Midtrans Token Created - Order: {$orderId}, Amount: {$amount}");

            return $this->corsResponse([
                'status'       => 'success',
                'order_id'     => $orderId,
                'snap_token'   => $snapToken,
                'redirect_url' => $redirectUrl,
            ]);

        } catch (Exception $e) {
            Log::error('Midtrans Snap Token Error: ' . $e->getMessage());
            return $this->corsResponse([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Handle Midtrans Webhook Notification
     */
    public function notificationCallback(Request $request)
    {
        if ($request->isMethod('OPTIONS')) {
            return $this->handleOptions();
        }

        try {
            $notification = new \Midtrans\Notification();

            $transaction = $notification->transaction_status;
            $type        = $notification->payment_type;
            $orderId     = $notification->order_id;
            $fraud       = $notification->fraud_status;

            Log::info("Midtrans Callback - Order: {$orderId}, Status: {$transaction}, Type: {$type}");

            // Determine final status
            $finalStatus = 'pending';
            if ($transaction == 'capture') {
                $finalStatus = ($type == 'credit_card' && $fraud == 'challenge') ? 'challenge' : 'settlement';
            } elseif ($transaction == 'settlement') {
                $finalStatus = 'settlement';
            } elseif (in_array($transaction, ['cancel', 'deny', 'expire'])) {
                $finalStatus = $transaction;
            }

            // Update DB record
            try {
                $this->ensurePaymentsTable();
                DB::table('payments')
                    ->where('order_id', $orderId)
                    ->update([
                        'transaction_status' => $finalStatus,
                        'payment_type'       => $type,
                        'fraud_status'       => $fraud,
                        'updated_at'         => now(),
                    ]);
            } catch (\Exception $dbErr) {
                Log::warning('Failed to update payment in DB: ' . $dbErr->getMessage());
            }

            return $this->corsResponse([
                'status'  => 'success',
                'message' => 'Notification handled',
            ]);

        } catch (Exception $e) {
            Log::error('Midtrans Notification Error: ' . $e->getMessage());
            return $this->corsResponse([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Check Transaction Status — first from DB, then from Midtrans directly
     */
    public function checkStatus($orderId)
    {
        try {
            // 1. Try local DB first (faster, no extra Midtrans API call)
            try {
                $this->ensurePaymentsTable();
                $record = DB::table('payments')->where('order_id', $orderId)->first();
                if ($record && in_array($record->transaction_status, ['settlement', 'capture'])) {
                    return $this->corsResponse([
                        'status'             => 'success',
                        'transaction_status' => $record->transaction_status,
                        'source'             => 'local_db',
                    ]);
                }
            } catch (\Exception $dbErr) {
                Log::warning('DB check failed, falling back to Midtrans API: ' . $dbErr->getMessage());
            }

            // 2. Check directly from Midtrans API
            $status = \Midtrans\Transaction::status($orderId);

            // Update DB with latest status
            try {
                DB::table('payments')
                    ->where('order_id', $orderId)
                    ->update([
                        'transaction_status' => $status->transaction_status,
                        'payment_type'       => $status->payment_type ?? null,
                        'updated_at'         => now(),
                    ]);
            } catch (\Exception $dbErr) {
                // non-fatal
            }

            return $this->corsResponse([
                'status'             => 'success',
                'transaction_status' => $status->transaction_status,
                'payment_type'       => $status->payment_type ?? null,
                'source'             => 'midtrans_api',
            ]);

        } catch (Exception $e) {
            Log::error('Midtrans Status Check Error: ' . $e->getMessage());
            return $this->corsResponse([
                'status'             => 'error',
                'transaction_status' => 'pending',
                'message'            => $e->getMessage(),
            ], 200); // Return 200 so Flutter can parse it
        }
    }

    /**
     * Get all payment history (for admin/reporting)
     */
    public function getHistory(Request $request)
    {
        try {
            $this->ensurePaymentsTable();
            $payments = DB::table('payments')
                ->orderBy('created_at', 'desc')
                ->limit(50)
                ->get();

            return $this->corsResponse([
                'status'   => 'success',
                'payments' => $payments,
            ]);
        } catch (Exception $e) {
            return $this->corsResponse([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
