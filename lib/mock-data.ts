import type { SavingGoal, Stock, Summary, Transaction } from "./types";

export const demoUserId = "demo-user";

export const mockTransactions: Transaction[] = [
  {
    id: "tx_salary",
    user_id: demoUserId,
    title: "工资到账",
    category: "收入",
    amount: 12800,
    happened_at: "2026-05-20T09:00:00.000Z",
    note: "五月工资"
  },
  {
    id: "tx_food",
    user_id: demoUserId,
    title: "午餐",
    category: "餐饮",
    amount: -38,
    happened_at: "2026-05-22T04:30:00.000Z",
    note: "工作日午餐"
  },
  {
    id: "tx_fund",
    user_id: demoUserId,
    title: "指数基金定投",
    category: "投资",
    amount: -600,
    happened_at: "2026-05-21T12:15:00.000Z",
    note: "自动扣款"
  }
];

export const mockSavingGoals: SavingGoal[] = [
  {
    id: "goal_travel",
    user_id: demoUserId,
    title: "夏日旅行基金",
    target_amount: 12000,
    current_amount: 6800,
    emoji: "✈️",
    due_date: "2026-08-01"
  },
  {
    id: "goal_emergency",
    user_id: demoUserId,
    title: "应急备用金",
    target_amount: 30000,
    current_amount: 17450,
    emoji: "🛟",
    due_date: null
  },
  {
    id: "goal_course",
    user_id: demoUserId,
    title: "成长课程",
    target_amount: 3000,
    current_amount: 960,
    emoji: "📚",
    due_date: "2026-06-30"
  }
];

export const mockStocks: Stock[] = [
  {
    code: "600519",
    name: "贵州茅台",
    price: "¥1,512.30",
    change: "+1.82%",
    risk: "中风险",
    pe: "PE 24.6",
    desc: "消费龙头，现金流稳健",
    favorite: true
  },
  {
    code: "300750",
    name: "宁德时代",
    price: "¥196.84",
    change: "+2.41%",
    risk: "中高风险",
    pe: "PE 18.9",
    desc: "新能源电池核心资产",
    favorite: false
  },
  {
    code: "000001",
    name: "平安银行",
    price: "¥11.42",
    change: "-0.36%",
    risk: "中风险",
    pe: "PE 5.4",
    desc: "低估值银行，股息稳定",
    favorite: false
  }
];

export function buildMockSummary(userId = demoUserId): Summary {
  const transactions = mockTransactions.map((item) => ({ ...item, user_id: userId }));
  const savingGoals = mockSavingGoals.map((item) => ({ ...item, user_id: userId }));
  const income = transactions.filter((item) => item.amount > 0).reduce((sum, item) => sum + item.amount, 0);
  const expense = Math.abs(transactions.filter((item) => item.amount < 0).reduce((sum, item) => sum + item.amount, 0));

  return {
    userId,
    balance: 48652,
    income,
    expense,
    healthScore: 86,
    transactions,
    savingGoals,
    stocks: mockStocks
  };
}
