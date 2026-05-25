import { NextResponse } from "next/server";
import { hasSupabaseConfig, supabaseRequest } from "@/lib/supabase-rest";
import type { Transaction } from "@/lib/types";

export async function POST(request: Request) {
  const payload = await request.json();
  const transaction = {
    user_id: payload.userId || "demo-user",
    title: String(payload.title || "未命名记录"),
    category: String(payload.category || "其他"),
    amount: Number(payload.amount || 0),
    happened_at: payload.happenedAt || new Date().toISOString(),
    note: payload.note || null
  };

  if (!transaction.amount) {
    return NextResponse.json({ error: "金额不能为空" }, { status: 400 });
  }

  if (!hasSupabaseConfig()) {
    return NextResponse.json({
      id: crypto.randomUUID(),
      ...transaction
    });
  }

  const [created] = await supabaseRequest<Transaction[]>({
    method: "POST",
    table: "transactions",
    body: transaction
  });

  return NextResponse.json(created);
}
