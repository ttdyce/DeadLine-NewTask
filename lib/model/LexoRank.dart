import 'dart:math';

class LexoRank {
  String? rank;
  LexoRank(this.rank);

  static final int DIGITS = 6;
  static final LexoRank MIN = LexoRank(''.padRight(DIGITS, 'A'));
  static final LexoRank MAX = LexoRank(''.padRight(DIGITS, 'Z'));

  static String? generate(LexoRank left, LexoRank right) {
    String rank = '';
    for (var i = 0; i < LexoRank.DIGITS; i++) {
      int leftCode = left.at(i);
      int rightCode = right.at(i);
      int middleCode = ((leftCode + rightCode) / 2).floor();

      if (leftCode == middleCode || rightCode == middleCode) {
        rank += String.fromCharCode(middleCode);
        continue;
      }

      return rank + String.fromCharCode(middleCode);
    }

    return null; // needed balancing
  }

  static List<LexoRank> balancing(List<LexoRank> ranks) {
    List<LexoRank> balancedRanks = [];
    num space = pow(26, DIGITS);
    int offsetInBetween = (space / (ranks.length - 1)).floor();
    print("space = $space");
    print("offset = $offsetInBetween");

    var pow26 = {for (var i = 5; i >= 0; i--) i: pow(26, i)};
    pow26.forEach(
      (k, v) => print("26 ^ $k = $v"),
    );

    int curr = 0;
    balancedRanks.add(LexoRank.MIN);

    curr += offsetInBetween;
    for (var i = 1; i < ranks.length - 1; i++) {
      print(
          "$curr (/26=${(log(curr) / log(26)).floor()} | ${(offsetInBetween / (pow(26, (log(curr) / log(26)).floor() - 1)).floor())} | ${curr % 26})");

      int x = curr;
      int remaining = curr;
      var digitNums = "";
      for (var k = 5; k >= 0; k--) {
        var v = pow(26, k).toInt();

        if (x / v < 0) {
          print('skip digit $k');
          continue;
        }

        var digitNum = (x / v).floor();
        remaining = x - (v * digitNum);
        // print(
        //     "$digitNum (${String.fromCharCode(digitNum + 'A'.codeUnits.first)}) .. $remaining");
        digitNums += String.fromCharCode(digitNum + 'A'.codeUnits.first);
        x = remaining;
      } 
      print(digitNums);
      balancedRanks.add(LexoRank(digitNums));

      curr += offsetInBetween;
    }

    balancedRanks.add(LexoRank.MAX);
    print("balancedRanks: ${balancedRanks.map((e) => e.rank)}");
    return balancedRanks;
  }

  int at(int i) {
    if (i < rank!.codeUnits.length) return rank!.codeUnits[i];
    return 'A'.codeUnits.first;
  }
}
