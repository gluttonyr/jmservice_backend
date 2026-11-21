// Account identifiers: a client signs up and signs in with an email address or a phone number.

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** Trimmed email, or null when empty. */
export function normalizeEmail(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const email = value.trim();
  return email ? email : null;
}

export function isValidEmail(email: string): boolean {
  return EMAIL_PATTERN.test(email);
}

/** Digits only ("+228 90 00 00 00" -> "22890000000"): two numbers are the same account when these match. */
export function phoneDigits(value: unknown): string {
  return typeof value === 'string' ? value.replace(/\D/g, '') : '';
}

/** Stored form "+22890000000", or null when there is no digit. */
export function normalizePhone(value: unknown): string | null {
  const digits = phoneDigits(value);
  return digits ? `+${digits}` : null;
}

/** A phone number has the international prefix and the subscriber number (8 digits in Togo). */
export function isValidPhone(phone: string): boolean {
  const digits = phoneDigits(phone);
  return digits.length >= 8 && digits.length <= 15;
}
