import { NextResponse } from "next/server";
import { buildMockSummary, mockStocks } from "@/lib/mock-data";
import { hasSupabaseConfig, supabaseRequest } from "@/lib/supabase-rest";
import type { SavingGoal, Transaction } from "@/lib/types";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get("userId") || "demo-user";

  if (!hasSupabaseConfig()) {
    return NextResponse.json(buildMockSummary(userId));
  }

  try {
    const [transactions, savingGoals] = await Promise.all([
      supabaseRequest<Transaction[]>({
        table: "transactions",
        query: `?user_id=eq.${encodeURIComponent(userId)}&order=happened_at.desc`
      }),
      supabaseRequest<SavingGoal[]>({
        table: "saving_goals",
        query: `?user_id=eq.${encodeURIComponent(userId)}&order=created_at.desc`
      })
    ]);

    const income = transactions.filter((item) => item.amount > 0).reduce((sum, item) => sum + item.amount, 0);
    const expense = Math.abs(transactions.filter((item) => item.amount < 0).reduce((sum, item) => sum + item.amount, 0));
    const saved = savingGoals.reduce((sum, item) => sum + item.current_amount, 0);

    return NextResponse.json({
      userId,
      balance: income - expense + saved,
      income,
      expense,
      healthScore: Math.min(96, Math.max(60, Math.round(72 + saved / 1500))),
      transactions,
      savingGoals,
      stocks: mockStocks
    });
  } catch (error) {
    console.error(error);
    return NextResponse.json(buildMockSummary(userId), {
      headers: { "x-growfi-data-source": "mock-fallback" }
    });
  }
}
