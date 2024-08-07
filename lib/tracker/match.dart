import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_rank.dart';
import 'package:parallel_stats/snack/basic.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/util/string.dart';

class Match extends StatelessWidget {
  final MatchModel match;
  final Function(BuildContext context)? onEdit;
  final Function(BuildContext context)? onDelete;

  const Match({
    super.key,
    required this.match,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit == null
              ? null
              : () {
                  onEdit!(context);
                },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: onDelete == null
              ? null
              : () {
                  var currentPlayer = match.paragon.title.isEmpty
                      ? match.paragon.name
                      : match.paragon.title;
                  var opponent = match.opponentParagon.title.isEmpty
                      ? match.opponentParagon.name
                      : match.opponentParagon.title;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(
                    reason: SnackBarClosedReason.dismiss,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    BasicSnack(
                      content: Text(
                          "Deleting ${currentPlayer.toTitleCase()} ${match.result.name} vs ${opponent.toTitleCase()}"),
                    ),
                  );
                  onDelete!(context);
                },
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Tooltip(
            message: match.playerTurn.value ? 'Going 1st' : 'Going 2nd',
            child: Icon(
              match.playerTurn.value
                  ? Icons.looks_one_rounded
                  : Icons.looks_two_rounded,
              color: match.playerTurn.value ? Colors.yellow[600] : Colors.cyan,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: FittedBox(
            child: ParagonAvatar(paragon: match.paragon),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Tooltip(
            message: match.result.tooltip,
            child: [MatchResultOption.draw, MatchResultOption.disconnect]
                    .contains(match.result)
                ? Icon(
                    match.result.icon,
                    color: match.result.color,
                  )
                : match.result == MatchResultOption.win
                    ? CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 12,
                        child: Baseline(
                          baseline: 18,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            "W",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: Baseline(
                          baseline: 18,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            "L",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ),
        Flexible(
          flex: 2,
          child: FittedBox(
            child: ParagonAvatar(paragon: match.opponentParagon),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (match.opponentUsername != null &&
                  match.opponentUsername!.isNotEmpty)
                FittedBox(
                  child: Text(
                    match.opponentUsername!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              FittedBox(
                child: RichText(
                  text: TextSpan(
                    children: [
                      if (match.mmrDelta != null)
                        TextSpan(
                          text: "${match.mmrDelta} MMR",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      if (match.mmrDelta != null && match.primeEarned != null)
                        TextSpan(
                          text: " • ",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      if (match.primeEarned != null)
                        TextSpan(
                          text:
                              "${match.primeEarned?.toStringAsPrecision(2)} PRIME",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  DateFormat.MMMMd().add_jm().format(match.matchTime.toLocal()),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
        if (match.opponentRank != null && match.opponentRank != Rank.unranked)
          Container(
            width: 60,
            padding: EdgeInsets.only(
              left: match.opponentRank!.index <= Rank.platinum.index ? 14 : 8,
              right: match.opponentRank!.index <= Rank.platinum.index ? 6 : 0,
            ),
            child: Tooltip(
              message: match.opponentRank?.name.toTitleCase(),
              child: Image.asset(
                "assets/ranks/${match.opponentRank?.name}.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        if (match.opponentRank == null || match.opponentRank == Rank.unranked)
          const SizedBox(
            width: 60,
          ),
      ],
    );
  }
}
