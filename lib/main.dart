import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popcorn Picks',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MovieScreen(),
    );
  }
}

class MovieScreen extends StatefulWidget {
  const MovieScreen({Key? key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  int pageNumber = 1;
  late List<String> movieNames;

  @override
  void initState() {
    super.initState();
    movieNames = <String>[];
    fetchData(pageNumber);
  }

  Future<void> fetchData(int page) async {
    final String apiUrl = 'https://yts.mx/api/v2/list_movies.json?limit=10&page=$page';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        final List<dynamic> moviesData = data["data"]['movies'];
        final List<Map<String, dynamic>> movies = List<Map<String, dynamic>>.from(moviesData.map((dynamic movie) {
          return movie as Map<String, dynamic>;
        }));
        movieNames = List<String>.from(movies.map((Map<String, dynamic> movieMap) => movieMap['title'] as String));
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popcorn Picks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade400,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.pink.shade50, Colors.pink.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: movieNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(movieNames[index], style: TextStyle(color: Colors.pink[900])),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (pageNumber > 1) {
                        setState(() {
                          pageNumber--;
                          fetchData(pageNumber);
                        });
                      }
                    },
                    child: const Text('Previous Page'),
                  ),
                  Text('Page $pageNumber', style: TextStyle(color: Colors.pink[900])),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        pageNumber++;
                        fetchData(pageNumber);
                      });
                    },
                    child: const Text('Next Page'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
