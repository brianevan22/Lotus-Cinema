<?php

namespace App\Http\Controllers\Api;

use App\Models\Transaksi;
use App\Http\Resources\TransaksiResource;
use Illuminate\Http\Request;

class TransaksiController extends \App\Http\Controllers\Controller
{
    public function index(Request $request)
    {
        $q = $request->query('search');
        $per = (int)($request->query('per_page', 15));
        $data = Transaksi::query()
            ->paginate($per);
        return TransaksiResource::collection($data);
    }

    public function show($id)
    {
        $row = Transaksi::findOrFail($id);
        return new TransaksiResource($row);
    }

    public function store(Request $request)
    {
        $payload = $request->all();
        $row = Transaksi::create($payload);
        return response()->json(new TransaksiResource($row), 201);
    }

    public function update(Request $request, $id)
    {
        $row = Transaksi::findOrFail($id);
        $row->fill($request->all())->save();
        return new TransaksiResource($row);
    }

    public function destroy($id)
    {
        $row = Transaksi::findOrFail($id);
        $row->delete();
        return response()->json(['deleted' => true]);
    }
}
