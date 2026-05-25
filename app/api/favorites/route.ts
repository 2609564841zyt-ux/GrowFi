import { NextResponse } from "next/server";
import { hasSupabaseConfig, supabaseRequest } from "@/lib/supabase-rest";

export async function POST(request: Request) {
  const payload = await request.json();
  const favorite = {
    user_id: payload.userId || "demo-user",
    stock_code: String(payload.stockCode || ""),
    stock_name: String(payload.stockName || "")
  };

  if (!favorite.stock_code) {
    return NextResponse.json({ error: "缺少股票代码" }, { status: 400 });
  }

  if (!hasSupabaseConfig()) {
    return NextResponse.json({ ok: true, ...favorite });
  }

  const [created] = await supabaseRequest<typeof favorite[]>({
    method: "POST",
    table: "favorite_stocks",
    body: favorite
  });

  return NextResponse.json(created);
}
