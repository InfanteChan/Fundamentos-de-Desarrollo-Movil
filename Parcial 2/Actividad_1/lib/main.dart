import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _url =
    'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';

void main() => runApp(const NflApp());

// ───────────────────────── Modelos ─────────────────────────

class Team {
  final String name;
  final String abbreviation;
  final String logo;
  final String score;
  final String record;
  final bool winner;

  Team({
    required this.name,
    required this.abbreviation,
    required this.logo,
    required this.score,
    required this.record,
    required this.winner,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>;
    final records = json['records'] as List?;
    return Team(
      name: team['displayName'] ?? '',
      abbreviation: team['abbreviation'] ?? '',
      logo: team['logo'] ?? '',
      score: json['score']?.toString() ?? '0',
      record: (records != null && records.isNotEmpty)
          ? records.first['summary'] ?? ''
          : '',
      winner: json['winner'] == true,
    );
  }
}

class Game {
  final String id;
  final DateTime date;
  final String statusDetail; // "Final", "10/4 - 1:00 PM EDT", "Q3 5:12"...
  final String state; // pre | in | post
  final String venue;
  final String broadcast;
  final Team home;
  final Team away;

  Game({
    required this.id,
    required this.date,
    required this.statusDetail,
    required this.state,
    required this.venue,
    required this.broadcast,
    required this.home,
    required this.away,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final comp = (json['competitions'] as List).first as Map<String, dynamic>;
    final competitors = comp['competitors'] as List;
    final home = competitors.firstWhere((c) => c['homeAway'] == 'home');
    final away = competitors.firstWhere((c) => c['homeAway'] == 'away');
    final statusType = json['status']['type'] as Map<String, dynamic>;

    return Game(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']).toLocal(),
      statusDetail: statusType['shortDetail'] ?? '',
      state: statusType['state'] ?? 'pre',
      venue: comp['venue']?['fullName'] ?? '',
      broadcast: comp['broadcast'] ?? '',
      home: Team.fromJson(home),
      away: Team.fromJson(away),
    );
  }
}

class Scoreboard {
  final int week;
  final List<Game> games;
  Scoreboard({required this.week, required this.games});
}

// ───────────────────────── API ─────────────────────────

Future<Scoreboard> fetchScoreboard() async {
  final res = await http.get(Uri.parse(_url));
  if (res.statusCode != 200) {
    throw Exception('Error del servidor (${res.statusCode})');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final events = (data['events'] as List?) ?? [];
  return Scoreboard(
    week: data['week']?['number'] ?? 0,
    games: events
        .map((e) => Game.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// ───────────────────────── UI ─────────────────────────

class NflApp extends StatelessWidget {
  const NflApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFL Scoreboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF013369), // azul NFL
        useMaterial3: true,
      ),
      home: const ScoreboardPage(),
    );
  }
}

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late Future<Scoreboard> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchScoreboard();
  }

  Future<void> _refresh() async {
    final f = fetchScoreboard();
    setState(() => _future = f);
    try {
      await f;
    } catch (_) {
      // El error se muestra en el FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // fondo rojo
      appBar: AppBar(
        backgroundColor: Colors.white, // para que el título azul se lea bien
        title: FutureBuilder<Scoreboard>(
          future: _future,
          builder: (_, snap) => Text(
            snap.hasData ? 'NFL · Semana ${snap.data!.week}' : 'NFL',
            style: const TextStyle(
                color: Color(0xFF013369), // azul oscuro
                fontWeight: FontWeight.bold,
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF013369)), // ícono de refrescar
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _refresh,
      ),
    ],
  ),
      body: FutureBuilder<Scoreboard>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 48),
                    const SizedBox(height: 12),
                    Text('No se pudieron cargar los datos\n${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final games = snapshot.data!.games;
          if (games.isEmpty) {
            return const Center(child: Text('No hay partidos disponibles'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: games.length,
              itemBuilder: (_, i) => GameCard(game: games[i]),
            ),
          );
        },
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;
  const GameCard({super.key, required this.game});

  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  String get _fecha {
    final d = game.date;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${_dias[d.weekday - 1]} ${d.day}/${d.month} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLive = game.state == 'in';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Estado del partido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  game.state == 'pre' ? _fecha : game.statusDetail,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLive ? Colors.red : scheme.primary,
                  ),
                ),
                if (game.broadcast.isNotEmpty)
                  Text(game.broadcast,
                      style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 12),
            TeamRow(team: game.away, showScore: game.state != 'pre'),
            const SizedBox(height: 8),
            TeamRow(team: game.home, showScore: game.state != 'pre'),
            if (game.venue.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.stadium_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(game.venue,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TeamRow extends StatelessWidget {
  final Team team;
  final bool showScore;
  const TeamRow({super.key, required this.team, required this.showScore});

  @override
  Widget build(BuildContext context) {
    final bold = team.winner ? FontWeight.bold : FontWeight.normal;
    return Row(
      children: [
        Image.network(
          team.logo,
          width: 40,
          height: 40,
          errorBuilder: (_, _, _) => const Icon(Icons.sports_football),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(team.name,
                  style: TextStyle(fontSize: 16, fontWeight: bold)),
              if (team.record.isNotEmpty)
                Text(team.record,
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (showScore)
          Text(team.score,
              style: TextStyle(fontSize: 24, fontWeight: bold)),
      ],
    );
  }
}