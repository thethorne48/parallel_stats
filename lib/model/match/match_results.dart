import 'package:flutter/foundation.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';

class MatchResults extends ChangeNotifier {
  Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>> _matchupCounts;

  MatchResults() : _matchupCounts = {};

  Future<void> init() async {
    final matchResults = await _fetchMatchResults();
    _matchupCounts = _initializeMatchupCounts(matchResults);
    notifyListeners();
  }

  Future<Set<MatchResult>> _fetchMatchResults() async {
    var results = await supabase.rpc<List<dynamic>>('get_player_results');
    return MatchResults._fromJson(results);
  }

  static Set<MatchResult> _fromJson(List<dynamic> json) {
    final results = <MatchResult>{};
    for (final result in json) {
      results.add(MatchResult.fromJson(result));
    }
    return results;
  }

  Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>>
      _initializeMatchupCounts(
    Set<MatchResult> matchResults,
  ) {
    Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>>
        matchupCounts = {};

    for (final match in matchResults) {
      if (!matchupCounts.containsKey(match.playerTurn)) {
        // The playerTurn is not in the map
        matchupCounts[match.playerTurn] = {
          match.paragon: {
            match.opponentParagon: MatchResultsCount.fromMatchResult(match),
          },
        };
      } else if (!matchupCounts[match.playerTurn]!.containsKey(match.paragon)) {
        // The playerTurn is in the map, but the paragon is not
        matchupCounts[match.playerTurn]![match.paragon] = {
          match.opponentParagon: MatchResultsCount.fromMatchResult(match),
        };
      } else if (!matchupCounts[match.playerTurn]![match.paragon]!
          .containsKey(match.opponentParagon)) {
        // The playerTurn and paragon are in the map, but the opponentParagon is not
        matchupCounts[match.playerTurn]![match.paragon]![
            match.opponentParagon] = MatchResultsCount.fromMatchResult(match);
      } else {
        // The playerTurn, paragon, and opponentParagon are in the map, increment the count
        matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon]!
            .increment(match);
      }
    }
    return matchupCounts;
  }

  MatchResultsCount _sumOpponentParagonMap(
    Map<Paragon, MatchResultsCount> opponentParagons, {
    Paragon? selectedParagon,
  }) {
    if (selectedParagon != null) {
      return opponentParagons[selectedParagon] ?? MatchResultsCount();
    }
    MatchResultsCount total = MatchResultsCount();
    for (final opponentParagonEntry in opponentParagons.entries) {
      total.addCounts(opponentParagonEntry.value);
    }
    return total;
  }

  MatchResultsCount _sumParagonMap(
    Map<Paragon, Map<Paragon, MatchResultsCount>> paragons, {
    Paragon? selectedParagon,
    Paragon? selectedOpponentParagon,
  }) {
    if (selectedParagon != null) {
      return _sumOpponentParagonMap(
        paragons[selectedParagon] ?? {},
        selectedParagon: selectedOpponentParagon,
      );
    }
    MatchResultsCount total = MatchResultsCount();
    for (final paragonEntry in paragons.entries) {
      total.addCounts(
        _sumOpponentParagonMap(
          paragonEntry.value,
          selectedParagon: selectedOpponentParagon,
        ),
      );
    }
    return total;
  }

  MatchResultsCount count({
    Paragon? paragon,
    Paragon? opponentParagon,
    PlayerTurn? playerTurn,
  }) {
    if (playerTurn != null) {
      return _sumParagonMap(
        _matchupCounts[playerTurn] ?? {},
        selectedParagon: paragon,
        selectedOpponentParagon: opponentParagon,
      );
    }
    MatchResultsCount total = MatchResultsCount();
    for (final turnEntry in _matchupCounts.entries) {
      total.addCounts(
        _sumParagonMap(
          turnEntry.value,
          selectedParagon: paragon,
          selectedOpponentParagon: opponentParagon,
        ),
      );
    }
    return total;
  }

  void recordMatch(MatchModel match) {
    if (!_matchupCounts.containsKey(match.playerTurn)) {
      // The playerTurn is not in the map
      _matchupCounts[match.playerTurn] = {
        match.paragon: {
          match.opponentParagon: MatchResultsCount.fromMatchModel(match),
        },
      };
    } else if (!_matchupCounts[match.playerTurn]!.containsKey(match.paragon)) {
      // The playerTurn is in the map, but the paragon is not
      _matchupCounts[match.playerTurn]![match.paragon] = {
        match.opponentParagon: MatchResultsCount.fromMatchModel(match),
      };
    } else if (!_matchupCounts[match.playerTurn]![match.paragon]!
        .containsKey(match.opponentParagon)) {
      // The playerTurn and paragon are in the map, but the opponentParagon is not
      _matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon] =
          MatchResultsCount.fromMatchModel(match);
    } else {
      // The playerTurn, paragon, and opponentParagon are in the map, increment the count
      _matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon]!
          .incrementFromModel(match);
    }
    notifyListeners();
  }

  void removeMatch(MatchModel match) {
    // TODO: Handle the case where a match can be removed twice by clicking before the removal animation completes
    _matchupCounts[match.playerTurn]?[match.paragon]?[match.opponentParagon]
        ?.decrementFromModel(match);
    notifyListeners();
  }

  void updateMatch(MatchModel oldMatch, MatchModel newMatch) {
    removeMatch(oldMatch);
    recordMatch(newMatch);
    notifyListeners();
  }
}