import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/tracker/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/util/string.dart';

class MatchModal extends StatefulWidget {
  final MatchModel match;

  const MatchModal({
    super.key,
    this.match = const MatchModel(
      paragon: Paragon.unknown,
      playerOne: true,
      result: MatchResult.win,
    ),
  });

  @override
  State<StatefulWidget> createState() => MatchModalState();
}

class MatchModalState extends State<MatchModal> {
  late Paragon paragon;
  late Paragon opponentParagon;
  late bool playerOne;
  late Set<MatchResult> result;
  TextEditingController opponentUsernameController = TextEditingController();
  TextEditingController mmrDeltaController = TextEditingController();
  TextEditingController primeController = TextEditingController();

  @override
  void initState() {
    paragon = widget.match.paragon;
    opponentParagon = widget.match.opponentParagon;
    playerOne = widget.match.playerOne;
    result = {widget.match.result};
    opponentUsernameController.text = widget.match.opponentUsername ?? '';
    mmrDeltaController.text = widget.match.mmrDelta?.toString() ?? '';
    primeController.text = widget.match.primeEarned?.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Match Result',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          onParagonSelected: (paragon) {
                            setState(() {
                              this.paragon = paragon;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: paragon),
                  ),
                  const Text('VS'),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          onParagonSelected: (paragon) {
                            setState(() {
                              opponentParagon = paragon;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: opponentParagon),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Play'),
                  ),
                  Tooltip(
                    message:
                        playerOne ? 'You play first' : 'Opponent plays first',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Switch(
                        value: !playerOne,
                        onChanged: (value) => setState(() {
                          playerOne = !value;
                        }),
                        trackColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                        ),
                        thumbColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Draw'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton(
                  emptySelectionAllowed: false,
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  // selectedIcon: const Icon(Icons.check),
                  selected: result,
                  segments: MatchResult.values
                      .map(
                        (gameResult) => ButtonSegment(
                          value: gameResult,
                          label: Text(gameResult.tooltip),
                        ),
                      )
                      .toList(),
                  onSelectionChanged: (selection) => setState(() {
                    result = selection;
                  }),
                ),
              ),
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: opponentUsernameController,
                          decoration: const InputDecoration(
                            labelText: 'Opponent Username',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 50,
                        child: TextField(
                          controller: mmrDeltaController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'MMR',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: primeController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'PRIME',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 64),
                    ElevatedButton(
                      onPressed: () {
                        var currentPlayer = paragon.title.isEmpty
                            ? paragon.name
                            : paragon.title;
                        var opponent = opponentParagon.title.isEmpty
                            ? opponentParagon.name
                            : opponentParagon.title;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            content: Text(
                              "Saving match: ${currentPlayer.toTitleCase()} vs ${opponent.toTitleCase()}",
                            ),
                          ),
                        );
                        Navigator.of(context).pop(
                          MatchModel(
                            id: widget.match.id,
                            paragon: paragon,
                            opponentParagon: opponentParagon,
                            playerOne: playerOne,
                            result: result.first,
                            matchTime: widget.match.matchTime,
                            opponentUsername:
                                opponentUsernameController.text.isEmpty
                                    ? null
                                    : opponentUsernameController.text,
                            mmrDelta: mmrDeltaController.text.isEmpty
                                ? null
                                : int.tryParse(mmrDeltaController.text),
                            primeEarned: primeController.text.isEmpty
                                ? null
                                : double.tryParse(primeController.text),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
