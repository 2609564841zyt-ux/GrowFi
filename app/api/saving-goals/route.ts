import { NextResponse } from "next/server";
import { hasSupabaseConfig, supabaseRequest } from "@/lib/supabase-rest";
import type { SavingGoal } from "@/lib/types";

export async function POST(request: Request) {
  const payload = await request.json();
  const goal = {
    user_id: payload.userId || "demo-user",
    title: String(payload.title || "新攒钱计划"),
    target_amount: Number(payload.targetAmount || 0),
    current_amount: Number(payload.currentAmount || 0),
    emoji: String(payload.emoji || "🌱"),
    due_date: payload.dueDate || null
  };

  if (!goal.target_amount) {
    return NextResponse.json({ error: "目标金额不能为空" }, { status: 400 });
  }

  if (!hasSupabaseConfig()) {
    return NextResponse.json({
      id: crypto.randomUUID(),
      ...goal
    });
  }

  const [created] = await supabaseRequest<SavingGoal[]>({
    method: "POST",
    table: "saving_goals",
    body: goal
  });

  return NextResponse.json(created);
}

export async function PATCH(request: Request) {
  const payload = await request.json();
  const goalId = String(payload.id || "");
  const amount = Number(payload.currentAmount || 0);

  if (!goalId) {
    return NextResponse.json({ error: "缺少计划 ID" }, { status: 400 });
  }

  if (!hasSupabaseConfig()) {
    return NextResponse.json({ id: goalId, current_amount: amount });
  }

  const [updated] = await supabaseRequest<SavingGoal[]>({
    method: "PATCH",
    table: "saving_goals",
    query: `?id=eq.${encodeURIComponent(goalId)}`,
    body: { current_amount: amount }
  });

  return NextResponse.json(updated);
}
