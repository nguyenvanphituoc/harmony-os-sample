const SETTLE_WINDOW_MS: number = 400;

export class SettleWindow {
  private lastToggleAt: number | null = null;
  private readonly windowMs: number;

  constructor(windowMs: number = SETTLE_WINDOW_MS) {
    this.windowMs = windowMs;
  }

  isSettling(now: number): boolean {
    return this.lastToggleAt !== null && now - this.lastToggleAt < this.windowMs;
  }

  mark(now: number): void {
    this.lastToggleAt = now;
  }
}
