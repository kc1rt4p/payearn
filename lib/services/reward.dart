import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntp/ntp.dart';

import '../data/models/wallet.dart';

class RewardService {
  DocumentReference walletRef;

  RewardService(String walletId) {
    walletRef = FirebaseFirestore.instance.collection('wallets').doc(walletId);
  }

  Future<DateTime> getLastRewardDate() async {
    final walletDoc = await walletRef.get();
    final wallet = Wallet.fromDocument(walletDoc);
    final Loyalty loyalty = wallet.loyalty;
    return loyalty.lastRewardReceived.toDate();
  }

  checkRewardCount() async {
    final currentDate = await NTP.now();
    try {
      final walletDoc = await walletRef.get();

      if (!walletDoc.exists) return null;

      final wallet = Wallet.fromDocument(walletDoc);

      final Loyalty loyalty = wallet.loyalty;

      if (loyalty.lastRewardReceived == null) {
        await walletRef.update({
          'loyalty.rewardCount': 10,
        });

        return 10;
      }

      final daysSinceLastReward =
          currentDate.difference(loyalty.lastRewardReceived.toDate()).inDays;

      if (daysSinceLastReward > 0) {
        await walletRef.update({
          'loyalty.rewardCount': 10,
        });

        return 10;
      }

      return loyalty.rewardCount;
    } catch (e) {
      return null;
    }
  }

  giveReward() async {
    try {
      await walletRef.update({
        'loyalty.lastRewardReceived': FieldValue.serverTimestamp(),
        'loyalty.amount': FieldValue.increment(1),
        'loyalty.lastUpdate': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('error giving reward');
      return false;
    }
  }
}
