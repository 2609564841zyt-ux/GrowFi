"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import type { SavingGoal, Stock, Summary, Transaction } from "@/lib/types";

const userId = "demo-user";
const tabs = ["首页", "记账", "理财", "我的"] as const;
const categories = ["餐饮", "交通", "收入", "投资", "购物", "其他"];

type Tab = (typeof tabs)[number];

export default function GrowFiApp() {
  const [summary, setSummary] = useState<Summary | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("首页");
  const [bookMode, setBookMode] = useState<"日历" | "小荷包">("日历");
  const [showAi, setShowAi] = useState(false);
  const [toast, setToast] = useState("");

  async function loadSummary() {
    const response = await fetch(`/api/summary?userId=${userId}`, { cache: "no-store" });
    setSummary(await response.json());
  }

  useEffect(() => {
    loadSummary();
  }, []);

  function notify(message: string) {
    setToast(message);
    window.setTimeout(() => setToast(""), 1700);
  }

  async function addTransaction(data: FormData) {
    const type = data.get("type");
    const rawAmount = Number(data.get("amount"));
    const amount = type === "expense" ? -Math.abs(rawAmount) : Math.abs(rawAmount);
    const response = await fetch("/api/transactions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        userId,
        title: data.get("title"),
        category: data.get("category"),
        amount,
        note: data.get("note")
      })
    });
    const created = (await response.json()) as Transaction;
    setSummary((current) =>
      current
        ? {
            ...current,
            transactions: [created, ...current.transactions],
            income: current.income + (created.amount > 0 ? created.amount : 0),
            expense: current.expense + (created.amount < 0 ? Math.abs(created.amount) : 0),
            balance: current.balance + created.amount
          }
        : current
    );
    notify("记账成功");
  }

  async function addGoal(data: FormData) {
    const response = await fetch("/api/saving-goals", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        userId,
        title: data.get("title"),
        targetAmount: data.get("targetAmount"),
        currentAmount: data.get("currentAmount"),
        emoji: data.get("emoji")
      })
    });
    const created = (await response.json()) as SavingGoal;
    setSummary((current) => (current ? { ...current, savingGoals: [created, ...current.savingGoals] } : current));
    notify("攒钱计划已创建");
  }

  async function favoriteStock(stock: Stock) {
    await fetch("/api/favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId, stockCode: stock.code, stockName: stock.name })
    });
    setSummary((current) =>
      current
        ? {
            ...current,
            stocks: current.stocks.map((item) => (item.code === stock.code ? { ...item, favorite: true } : item))
          }
        : current
    );
    notify("已加入自选");
  }

  const content = useMemo(() => {
    if (!summary) return <LoadingScreen />;
    if (activeTab === "首页") return <Home summary={summary} />;
    if (activeTab === "记账") {
      return (
        <Accounting
          mode={bookMode}
          setMode={setBookMode}
          summary={summary}
          addTransaction={addTransaction}
          addGoal={addGoal}
        />
      );
    }
    if (activeTab === "理财") {
      return <Market stocks={summary.stocks} onAi={() => setShowAi(true)} onFavorite={favoriteStock} />;
    }
    return <Profile summary={summary} />;
  }, [activeTab, bookMode, summary]);

  return (
    <main className="app-shell">
      <section className="phone">
        <div className="status-bar">
          <b>9:41</b>
          <span>5G · 86%</span>
        </div>
        <div className="screen">{content}</div>
        <nav className="tabbar" aria-label="底部导航">
          {tabs.map((tab) => (
            <button key={tab} className={activeTab === tab ? "active" : ""} onClick={() => setActiveTab(tab)}>
              <span>{tabIcon(tab)}</span>
              {tab}
            </button>
          ))}
        </nav>
        {showAi && <AiSheet onClose={() => setShowAi(false)} />}
        {toast && <div className="toast">{toast}</div>}
      </section>
    </main>
  );
}

function Home({ summary }: { summary: Summary }) {
  return (
    <div className="page">
      <header className="home-header">
        <div>
          <h1>GrowFi</h1>
          <p>让每一次记账都长出新叶</p>
        </div>
        <button className="water-button">浇水<br />+12</button>
      </header>
      <section className="hero-plant">
        <div className="bubble left">+¥8,200<br />工资</div>
        <div className="bubble right">-¥386<br />餐饮</div>
        <img src="/assets/plant.png" alt="GrowFi 成长植物" />
      </section>
      <section className="balance-card">
        <p>总资产</p>
        <strong>{currency(summary.balance)}</strong>
        <div className="metric-grid">
          <span>收入 {currency(summary.income)}</span>
          <span>支出 {currency(summary.expense)}</span>
        </div>
      </section>
      <section className="two-card">
        <article>
          <p>财务健康度</p>
          <strong>{summary.healthScore}</strong>
          <div className="bar"><i style={{ width: `${summary.healthScore}%` }} /></div>
        </article>
        <article>
          <p>小希建议</p>
          <b>本月餐饮支出偏高</b>
          <span>建议开启工作日午餐预算提醒。</span>
        </article>
      </section>
      <GoalList goals={summary.savingGoals.slice(0, 2)} />
    </div>
  );
}

function Accounting({
  mode,
  setMode,
  summary,
  addTransaction,
  addGoal
}: {
  mode: "日历" | "小荷包";
  setMode: (mode: "日历" | "小荷包") => void;
  summary: Summary;
  addTransaction: (data: FormData) => Promise<void>;
  addGoal: (data: FormData) => Promise<void>;
}) {
  return (
    <div className="page">
      <PageTitle title="记账" subtitle="记录今天，也规划未来" />
      <div className="segmented">
        {(["日历", "小荷包"] as const).map((item) => (
          <button key={item} className={mode === item ? "active" : ""} onClick={() => setMode(item)}>{item}</button>
        ))}
      </div>
      {mode === "日历" ? (
        <>
          <TransactionForm onSubmit={addTransaction} />
          <section className="card">
            <h2>最近记录</h2>
            <div className="list">
              {summary.transactions.map((item) => (
                <div className="list-row" key={item.id}>
                  <span>{item.category.slice(0, 1)}</span>
                  <div>
                    <b>{item.title}</b>
                    <p>{item.category} · {new Date(item.happened_at).toLocaleDateString("zh-CN")}</p>
                  </div>
                  <strong className={item.amount > 0 ? "up" : "down"}>{signedCurrency(item.amount)}</strong>
                </div>
              ))}
            </div>
          </section>
        </>
      ) : (
        <>
          <GoalForm onSubmit={addGoal} />
          <GoalList goals={summary.savingGoals} />
        </>
      )}
    </div>
  );
}

function TransactionForm({ onSubmit }: { onSubmit: (data: FormData) => Promise<void> }) {
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    await onSubmit(new FormData(event.currentTarget));
    event.currentTarget.reset();
  }

  return (
    <form className="card form" onSubmit={submit}>
      <h2>添加一笔</h2>
      <input name="title" placeholder="例如 午餐 / 工资到账" required />
      <div className="form-grid">
        <input name="amount" type="number" min="0.01" step="0.01" placeholder="金额" required />
        <select name="type" defaultValue="expense">
          <option value="expense">支出</option>
          <option value="income">收入</option>
        </select>
      </div>
      <select name="category" defaultValue="餐饮">
        {categories.map((item) => <option key={item}>{item}</option>)}
      </select>
      <input name="note" placeholder="备注，可不填" />
      <button className="primary">保存记账</button>
    </form>
  );
}

function GoalForm({ onSubmit }: { onSubmit: (data: FormData) => Promise<void> }) {
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    await onSubmit(new FormData(event.currentTarget));
    event.currentTarget.reset();
  }

  return (
    <form className="card form" onSubmit={submit}>
      <h2>新建存钱计划</h2>
      <input name="title" placeholder="例如 旅行基金" required />
      <div className="form-grid">
        <input name="targetAmount" type="number" min="1" placeholder="目标金额" required />
        <input name="currentAmount" type="number" min="0" placeholder="已攒金额" defaultValue="0" />
      </div>
      <input name="emoji" placeholder="图标，例如 ✈️" defaultValue="🌱" />
      <button className="primary">创建计划</button>
    </form>
  );
}

function Market({ stocks, onAi, onFavorite }: { stocks: Stock[]; onAi: () => void; onFavorite: (stock: Stock) => void }) {
  return (
    <div className="page">
      <PageTitle title="理财市场" subtitle="先学习，再做决定" />
      <button className="ai-entry" onClick={onAi}>AI 帮选 · 查看今日机会</button>
      <div className="chip-row"><span>推荐</span><span>低估值</span><span>新能源</span><span>消费</span></div>
      <section className="stock-list">
        {stocks.map((stock) => (
          <article className="stock-card" key={stock.code}>
            <div>
              <b>{stock.name}</b>
              <p>{stock.code} · {stock.desc}</p>
              <small>{stock.pe} · {stock.risk}</small>
            </div>
            <div className="stock-side">
              <strong>{stock.price}</strong>
              <span className={stock.change.startsWith("-") ? "down" : "up"}>{stock.change}</span>
              <button onClick={() => onFavorite(stock)}>{stock.favorite ? "已自选" : "收藏"}</button>
            </div>
          </article>
        ))}
      </section>
    </div>
  );
}

function Profile({ summary }: { summary: Summary }) {
  return (
    <div className="page">
      <section className="profile-head">
        <div className="avatar">G</div>
        <h1>GrowFi 用户</h1>
        <p>连续记录 18 天 · 小植物 Lv.3</p>
        <div className="profile-stats">
          <span><b>{summary.transactions.length}</b>笔记录</span>
          <span><b>{summary.savingGoals.length}</b>个计划</span>
          <span><b>{summary.healthScore}</b>健康分</span>
        </div>
      </section>
      <section className="card menu">
        {["账户安全", "预算提醒", "数据导出", "理财课堂", "帮助与反馈"].map((item) => (
          <button key={item}>{item}<span>›</span></button>
        ))}
      </section>
    </div>
  );
}

function GoalList({ goals }: { goals: SavingGoal[] }) {
  return (
    <section className="card">
      <h2>储蓄目标</h2>
      <div className="list">
        {goals.map((goal) => {
          const percent = Math.min(100, Math.round((goal.current_amount / goal.target_amount) * 100));
          return (
            <div className="goal" key={goal.id}>
              <span>{goal.emoji}</span>
              <div>
                <b>{goal.title}</b>
                <p>{currency(goal.current_amount)} / {currency(goal.target_amount)}</p>
                <div className="bar"><i style={{ width: `${percent}%` }} /></div>
              </div>
              <strong>{percent}%</strong>
            </div>
          );
        })}
      </div>
    </section>
  );
}

function AiSheet({ onClose }: { onClose: () => void }) {
  return (
    <div className="sheet-backdrop">
      <section className="ai-sheet">
        <button className="close" onClick={onClose}>×</button>
        <h2>AI 智能选股</h2>
        <p>基于你的中等风险偏好，今日更适合关注现金流稳、估值合理的行业龙头。</p>
        <div className="insight">
          <b>精选推荐</b>
          <span>贵州茅台 · 宁德时代 · 平安银行</span>
        </div>
        <div className="warning">提示：内容仅用于学习和辅助分析，不构成投资建议。</div>
      </section>
    </div>
  );
}

function PageTitle({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <header className="page-title">
      <h1>{title}</h1>
      <p>{subtitle}</p>
    </header>
  );
}

function LoadingScreen() {
  return <div className="loading">GrowFi 正在加载...</div>;
}

function tabIcon(tab: Tab) {
  return tab === "首页" ? "⌂" : tab === "记账" ? "＋" : tab === "理财" ? "↗" : "●";
}

function currency(value: number) {
  return `¥${Math.round(value).toLocaleString("zh-CN")}`;
}

function signedCurrency(value: number) {
  return `${value >= 0 ? "+" : "-"}${currency(Math.abs(value))}`;
}
