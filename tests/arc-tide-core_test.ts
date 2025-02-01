import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create a new goal",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const block = chain.mineBlock([
      Tx.contractCall(
        "arc-tide-core",
        "create-goal",
        [types.utf8("Learn Clarity"), types.uint(1640995200)],
        wallet_1.address
      ),
    ]);
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result.expectOk(), "u0");
  },
});
