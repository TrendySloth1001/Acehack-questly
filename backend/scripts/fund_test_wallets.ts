// One-off script: fund both test wallets so they can participate in the escrow flow
import { algorandService } from '../src/modules/algorand/algorand.service';
import { prisma } from '../src/config/database';

async function main() {
  const users = await prisma.user.findMany({
    select: { id: true, name: true, walletAddress: true }
  });

  console.log('Funding wallets...');
  for (const u of users) {
    if (!u.walletAddress) { console.log(u.name, '- no wallet, skip'); continue; }
    try {
      const result = await algorandService.dispense(u.walletAddress, 10);
      console.log(`${u.name}: dispensed 10 ALGO → txId ${result.txId}`);
    } catch (e: any) {
      console.error(`${u.name}: failed - ${e.message}`);
    }
  }

  const bal = await algorandService.getBalance('6JAXYZGQWWNPFZE23MLH54XQ3NLIAZWB4KE7ZGX33KJ6N3LTDHB2ILXOTU');
  console.log('Abhinand new balance:', bal.balanceAlgo, 'ALGO (spendable:', bal.balanceAlgo - bal.minBalance - 0.001, 'ALGO)');

  await prisma.$disconnect();
}

main().catch(console.error);

