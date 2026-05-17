const state = {
  page: "home",
  category: "餐饮",
  productType: "稳健",
  transactions: [
    { title: "便利店", meta: "今天 08:42 · 餐饮", amount: -28, icon: "餐", color: "#18a058" },
    { title: "基金定投", meta: "昨天 20:10 · 投资", amount: -600, icon: "投", color: "#4b7bec" },
    { title: "工资入账", meta: "04月30日 · 收入", amount: 12800, icon: "收", color: "#f2b84b" },
  ],
};

const icons = {
  bell: '<svg viewBox="0 0 24 24"><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></svg>',
  plus: '<svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>',
  scan: '<svg viewBox="0 0 24 24"><path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3M8 12h8"/></svg>',
  arrow: '<svg viewBox="0 0 24 24"><path d="m9 18 6-6-6-6"/></svg>',
};

function money(value) {
  const sign = value < 0 ? "-" : "+";
  return `${sign}¥${Math.abs(value).toLocaleString("zh-CN")}`;
}

function showToast(message) {
  let toast = document.querySelector(".toast");
  if (!toast) {
    toast = document.createElement("div");
    toast.className = "toast";
    document.querySelector(".app-screen").appendChild(toast);
  }
  toast.textContent = message;
  toast.classList.add("show");
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => toast.classList.remove("show"), 1800);
}

function assetRow(title, value, delta, icon, color, negative = false) {
  return `
    <article class="asset-row">
      <span class="asset-icon" style="background:${color}">${icon}</span>
      <div class="asset-main">
        <h3>${title}</h3>
        <p class="list-meta">实时估值</p>
      </div>
      <div class="row-end">
        <div class="money">¥${value}</div>
        <p class="${negative ? "down" : "up"}">${delta}</p>
      </div>
    </article>
  `;
}

function transactionRow(item) {
  return `
    <article class="list-row">
      <span class="category-icon" style="background:${item.color}">${item.icon}</span>
      <div class="list-main">
        <h3>${item.title}</h3>
        <p class="list-meta">${item.meta}</p>
      </div>
      <strong class="${item.amount > 0 ? "up" : "down"}">${money(item.amount)}</strong>
    </article>
  `;
}

function menuRow(title, meta, icon, color, on) {
  return `
    <article class="switch-row">
      <span class="mini-icon" style="background:${color}">${icon}</span>
      <div class="list-main">
        <h3>${title}</h3>
        <p class="list-meta">${meta}</p>
      </div>
      <button class="switch ${on ? "on" : ""}" type="button" aria-label="${title}"></button>
    </article>
  `;
}

function menuLink(title, meta, icon, color) {
  return `
    <article class="list-row clickable" data-action="menu">
      <span class="mini-icon" style="background:${color}">${icon}</span>
      <div class="list-main">
        <h3>${title}</h3>
        <p class="list-meta">${meta}</p>
      </div>
      ${icons.arrow}
    </article>
  `;
}

function renderHome() {
  document.getElementById("home-page").innerHTML = `
    <div class="top-row">
      <div>
        <p class="eyebrow">晚上好，继续让钱生长</p>
        <h1>资产总览</h1>
      </div>
      <button class="icon-btn" type="button" data-action="notice" aria-label="通知">${icons.bell}</button>
    </div>

    <article class="hero-card">
      <p class="balance-label">总资产（元）</p>
      <div class="balance">¥128,560.42</div>
      <div class="gain">本月收益 +¥2,438.18</div>
      <div class="hero-actions">
        <button type="button" data-goto="accounting">记一笔</button>
        <button type="button" data-goto="finance">去理财</button>
      </div>
    </article>

    <div class="grid-2">
      <article class="metric-card">
        <p class="metric-caption">本月支出</p>
        <div class="metric-value">¥5,642</div>
        <p class="subtle">比上月少 12%</p>
      </article>
      <article class="metric-card">
        <p class="metric-caption">可用预算</p>
        <div class="metric-value">¥3,358</div>
        <p class="subtle">还可用 37%</p>
      </article>
    </div>

    <div class="section-head">
      <h2>资产分布</h2>
      <button class="link-btn" type="button" data-goto="finance">查看</button>
    </div>
    <div class="asset-list">
      ${assetRow("活期余额", "48,320.00", "+1.8%", "现", "#18a058")}
      ${assetRow("稳健基金", "62,400.42", "+4.6%", "基", "#4b7bec")}
      ${assetRow("黄金账户", "17,840.00", "-0.4%", "金", "#f2b84b", true)}
    </div>

    <div class="chart-card">
      <div class="summary-row">
        <h2>近 7 日收支</h2>
        <span class="tag">自动同步</span>
      </div>
      <div class="bars">${[48, 72, 38, 86, 62, 108, 54].map((height) => `<span class="bar" style="height:${height}px"></span>`).join("")}</div>
    </div>
  `;
}

function renderAccounting() {
  const categories = [
    ["餐饮", "餐", "#18a058"],
    ["交通", "行", "#1b8a8f"],
    ["购物", "购", "#e35d5b"],
    ["投资", "投", "#4b7bec"],
    ["住房", "住", "#f2b84b"],
    ["娱乐", "乐", "#8b6eea"],
    ["医疗", "医", "#20b7a8"],
    ["收入", "收", "#111827"],
  ];

  document.getElementById("accounting-page").innerHTML = `
    <div class="top-row">
      <div>
        <p class="eyebrow">快速记录每一笔现金流</p>
        <h1>记账</h1>
      </div>
      <button class="icon-btn" type="button" data-action="scan" aria-label="扫描票据">${icons.scan}</button>
    </div>

    <form class="form-card" id="record-form">
      <input class="amount-input" id="amount-input" inputmode="decimal" placeholder="¥0.00" aria-label="金额" />
      <div class="category-grid">
        ${categories.map(([name, label, color]) => `
          <button class="category-chip ${state.category === name ? "active" : ""}" type="button" data-category="${name}">
            <span class="category-icon" style="background:${color}">${label}</span>
            <span>${name}</span>
          </button>
        `).join("")}
      </div>
      <button class="primary-btn" type="submit">保存记录</button>
    </form>

    <div class="section-head">
      <h2>本月预算</h2>
      <button class="link-btn" type="button" data-action="budget">调整</button>
    </div>
    <article class="budget-card">
      <div class="summary-row">
        <div>
          <h3>生活预算</h3>
          <p class="subtle">已用 ¥5,642 / ¥9,000</p>
        </div>
        <strong>63%</strong>
      </div>
      <div class="progress-track"><div class="progress-fill" style="--value:63%"></div></div>
    </article>

    <div class="section-head">
      <h2>最近记录</h2>
      <button class="link-btn" type="button" data-action="export">导出</button>
    </div>
    <div class="transaction-list">${state.transactions.map(transactionRow).join("")}</div>
  `;
}

function renderFinance() {
  const products = [
    { type: "稳健", title: "四季稳盈组合", rate: "4.28%", meta: "中低风险 · 30 天持有", tag: "热门" },
    { type: "稳健", title: "现金增强计划", rate: "3.16%", meta: "低风险 · 随取灵活", tag: "灵活" },
    { type: "进阶", title: "指数成长策略", rate: "8.72%", meta: "中风险 · 长期配置", tag: "成长" },
    { type: "进阶", title: "全球精选基金", rate: "6.45%", meta: "中高风险 · 分散投资", tag: "精选" },
  ].filter((item) => item.type === state.productType);

  document.getElementById("finance-page").innerHTML = `
    <div class="top-row">
      <div>
        <p class="eyebrow">按你的风险偏好推荐</p>
        <h1>理财</h1>
      </div>
      <button class="icon-btn" type="button" data-action="plus" aria-label="新增自选">${icons.plus}</button>
    </div>

    <article class="hero-card finance-hero">
      <p class="balance-label">持仓收益</p>
      <div class="balance">+¥12,846</div>
      <div class="gain">累计收益率 +11.8%</div>
      <div class="hero-actions">
        <button type="button" data-filter="稳健">稳健计划</button>
        <button type="button" data-filter="进阶">进阶组合</button>
      </div>
    </article>

    <div class="filter-row" role="tablist" aria-label="理财类型">
      <button type="button" class="${state.productType === "稳健" ? "active" : ""}" data-filter="稳健">稳健</button>
      <button type="button" class="${state.productType === "进阶" ? "active" : ""}" data-filter="进阶">进阶</button>
    </div>

    <div class="section-head">
      <h2>精选产品</h2>
      <span class="tag">${state.productType}</span>
    </div>
    ${products.map((item) => `
      <article class="product-card">
        <div class="product-top">
          <div>
            <h3>${item.title}</h3>
            <p class="subtle">${item.meta}</p>
          </div>
          <span class="tag">${item.tag}</span>
        </div>
        <div>
          <div class="rate">${item.rate}</div>
          <p class="subtle">近一年收益率</p>
        </div>
        <button class="ghost-btn" type="button" data-action="buy" data-product="${item.title}">立即配置</button>
      </article>
    `).join("")}
  `;
}

function renderProfile() {
  document.getElementById("profile-page").innerHTML = `
    <div class="profile-head">
      <div class="summary-row">
        <span class="avatar">G</span>
        <div>
          <p class="eyebrow">GrowFi Plus</p>
          <h1>陈安</h1>
          <p class="subtle">风险等级：平衡型</p>
        </div>
      </div>
      <button class="icon-btn" type="button" data-action="settings" aria-label="设置">${icons.arrow}</button>
    </div>

    <article class="level-card">
      <div class="summary-row">
        <div>
          <h2>财富成长等级 Lv.6</h2>
          <p class="level-note">再完成 2 个目标升级</p>
        </div>
        <strong>78%</strong>
      </div>
      <div class="progress-track"><div class="progress-fill" style="--value:78%"></div></div>
    </article>

    <div class="section-head">
      <h2>账户服务</h2>
      <button class="link-btn" type="button" data-action="help">帮助</button>
    </div>
    <div class="menu-list">
      ${menuRow("自动记账", "开启后同步账单提醒", "自", "#18a058", true)}
      ${menuRow("收益通知", "每日 21:00 推送收益摘要", "益", "#4b7bec", true)}
      ${menuRow("预算预警", "超过 80% 自动提醒", "预", "#e35d5b", false)}
      ${menuLink("银行卡", "3 张卡已绑定", "卡", "#f2b84b")}
      ${menuLink("安全中心", "面容与支付密码", "安", "#111827")}
    </div>
  `;
}

function renderAll() {
  renderHome();
  renderAccounting();
  renderFinance();
  renderProfile();
}

function setPage(page) {
  state.page = page;
  document.querySelectorAll(".page").forEach((node) => {
    node.classList.toggle("active", node.dataset.page === page);
  });
  document.querySelectorAll(".nav-item").forEach((node) => {
    node.classList.toggle("active", node.dataset.target === page);
  });
}

document.addEventListener("click", (event) => {
  const target = event.target.closest("button, .clickable");
  if (!target) return;

  if (target.dataset.target) setPage(target.dataset.target);
  if (target.dataset.goto) setPage(target.dataset.goto);
  if (target.dataset.category) {
    state.category = target.dataset.category;
    renderAccounting();
  }
  if (target.dataset.filter) {
    state.productType = target.dataset.filter;
    renderFinance();
  }
  if (target.classList.contains("switch")) target.classList.toggle("on");

  const messages = {
    notice: "暂无新的资产提醒",
    scan: "票据扫描已准备好",
    budget: "预算调整面板已打开",
    export: "账单已生成导出任务",
    plus: "已加入自选关注",
    settings: "设置入口",
    help: "客服在线，随时帮你",
    menu: "功能详情已打开",
  };

  if (target.dataset.action === "buy") {
    showToast(`${target.dataset.product} 已加入配置清单`);
  } else if (messages[target.dataset.action]) {
    showToast(messages[target.dataset.action]);
  }
});

document.addEventListener("submit", (event) => {
  if (event.target.id !== "record-form") return;
  event.preventDefault();
  const input = document.getElementById("amount-input");
  const value = Number.parseFloat(input.value.replace(/[^\d.]/g, ""));
  if (!value) {
    showToast("请输入金额");
    return;
  }
  const isIncome = state.category === "收入";
  state.transactions.unshift({
    title: state.category,
    meta: "刚刚 · 手动记录",
    amount: isIncome ? value : -value,
    icon: isIncome ? "收" : state.category.slice(0, 1),
    color: isIncome ? "#111827" : "#18a058",
  });
  input.value = "";
  renderAccounting();
  showToast("记录已保存");
});

renderAll();
setPage("home");
