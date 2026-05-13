#!/usr/bin/env node
/**
 * Mermaid 構文バリデーター
 *
 * マークダウンテキストから ```mermaid ブロックを抽出し、構文を検証する。
 *
 * 使い方:
 *   echo "マークダウン" | node .claude/scripts/validate-mermaid.mjs
 *   node .claude/scripts/validate-mermaid.mjs < file.md
 *   node .claude/scripts/validate-mermaid.mjs --text '```mermaid\nflowchart LR\n  A --> B\n```'
 *
 * 終了コード:
 *   0: 全て有効 or Mermaid ブロックなし
 *   1: 1つ以上のバリデーションエラー
 */

// --- Node.js 環境セットアップ（mermaid は ブラウザ向けのため DOM が必要）---
import { JSDOM } from "jsdom";
import createDOMPurify from "dompurify";

const dom = new JSDOM("<!DOCTYPE html><html><body></body></html>");
globalThis.window = dom.window;
globalThis.document = dom.window.document;
Object.defineProperty(globalThis, "navigator", {
  value: dom.window.navigator,
  writable: true,
});
globalThis.DOMParser = dom.window.DOMParser;
globalThis.SVGElement = dom.window.SVGElement || class SVGElement {};
globalThis.DOMPurify = createDOMPurify(dom.window);

// --- mermaid 読み込み ---
const mermaid = (await import("mermaid")).default;
mermaid.initialize({ startOnLoad: false });

// --- ユーティリティ ---
function extractMermaidBlocks(markdown) {
  const regex = /```mermaid\n([\s\S]*?)```/g;
  const blocks = [];
  let match;
  while ((match = regex.exec(markdown)) !== null) {
    blocks.push({
      content: match[1].trim(),
      position: match.index,
      line: markdown.substring(0, match.index).split("\n").length,
    });
  }
  return blocks;
}

async function validateBlock(block, index) {
  try {
    await mermaid.parse(block.content);
    return { index, line: block.line, valid: true };
  } catch (e) {
    const message = e.message || String(e);
    const match = message.match(/Parse error on line \d+:[\s\S]*?got '.*?'/);
    const summary = match ? match[0] : message.split("\n")[0];
    return { index, line: block.line, valid: false, error: summary };
  }
}

// --- メイン ---
async function main() {
  let input;

  const textArgIndex = process.argv.indexOf("--text");
  if (textArgIndex !== -1 && process.argv[textArgIndex + 1]) {
    input = process.argv[textArgIndex + 1].replace(/\\n/g, "\n");
  } else {
    const chunks = [];
    for await (const chunk of process.stdin) {
      chunks.push(chunk);
    }
    input = Buffer.concat(chunks).toString("utf-8");
  }

  if (!input.trim()) {
    console.log("⚠ 入力が空です");
    process.exit(0);
  }

  const blocks = extractMermaidBlocks(input);

  if (blocks.length === 0) {
    console.log("✓ Mermaid ブロックなし");
    process.exit(0);
  }

  console.log(`${blocks.length} 個の Mermaid ブロックを検出\n`);

  const results = [];
  for (let i = 0; i < blocks.length; i++) {
    results.push(await validateBlock(blocks[i], i));
  }

  let hasError = false;
  for (const result of results) {
    if (result.valid) {
      console.log(`✓ ブロック ${result.index + 1} (行 ${result.line}): OK`);
    } else {
      console.log(
        `✗ ブロック ${result.index + 1} (行 ${result.line}): エラー`
      );
      console.log(`  ${result.error}\n`);
      hasError = true;
    }
  }

  if (hasError) {
    console.log("\n✗ Mermaid バリデーションエラーあり");
    process.exit(1);
  } else {
    console.log("\n✓ 全 Mermaid ブロックが有効");
    process.exit(0);
  }
}

main().catch((e) => {
  console.error("スクリプトエラー:", e);
  process.exit(1);
});
