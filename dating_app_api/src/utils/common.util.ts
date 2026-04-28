/**
 * General utilities.
 */

export const formatDate = (date: Date | string | number) => {
  return new Date(date).toISOString();
};

const getSensitiveWords = (): string[] => {
  const raw = process.env.SENSITIVE_WORDS || '';
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
};

export const filterSensitiveWords = (text: string) => {
  const sensitiveWords = getSensitiveWords();
  if (sensitiveWords.length === 0) return text;

  let filteredText = text;
  for (const word of sensitiveWords) {
    const reg = new RegExp(word, 'g');
    filteredText = filteredText.replace(reg, '**');
  }
  return filteredText;
};

