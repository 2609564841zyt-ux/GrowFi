export type Transaction = {
  id: string;
  user_id: string;
  title: string;
  category: string;
  amount: number;
  happened_at: string;
  note?: string | null;
};

export type SavingGoal = {
  id: string;
  user_id: string;
  title: string;
  target_amount: number;
  current_amount: number;
  emoji: string;
  due_date?: string | null;
};

export type Stock = {
  code: string;
  name: string;
  price: string;
  change: string;
  risk: string;
  pe: string;
  desc: string;
  favorite: boolean;
};

export type Summary = {
  userId: string;
  balance: number;
  income: number;
  expense: number;
  healthScore: number;
  transactions: Transaction[];
  savingGoals: SavingGoal[];
  stocks: Stock[];
};
