import 'package:flutter/material.dart';
import '../Services/news_service.dart';
import '../Models/news_article.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String selectedCountry = 'global';
  late Future<List<NewsArticle>> newsArticles;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void fetchNews() {
    newsArticles = NewsService().fetchAgricultureNews(selectedCountry);
  }

  void updateNews(String country) {
    setState(() {
      selectedCountry = country;
      fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agriculture News'),
        backgroundColor: const Color.fromRGBO(223, 240, 227, 1),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),
      body: Container(
        color: Color.fromRGBO(223, 240, 227, 1),
        child: FutureBuilder<List<NewsArticle>>(
          future: newsArticles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching news: ${snapshot.error}',
                  style: TextStyle(color: Colors.green),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No agriculture news available',
                  style: TextStyle(color: Colors.green),
                ),
              );
            }

            final filteredArticles = snapshot.data!.where((article) =>
            !article.title.toLowerCase().contains('[removed]') &&
                !(article.sourceName?.toLowerCase() == '[removed]')).toList();

            if (filteredArticles.isEmpty) {
              return Center(
                child: Text(
                  'No valid agriculture news available',
                  style: TextStyle(color: Colors.green),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return NewsCard(article: article);
              },
            );
          },
        ),
      ),
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select News Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Global Agriculture News'),
                onTap: () {
                  updateNews('global');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Local Agriculture News'),
                onTap: () {
                  updateNews('in');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl != null)
            Image.network(
              article.imageUrl!,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.description,
              style: TextStyle(color: Colors.green),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Open article URL using a package like url_launcher
              },
              child: Text(
                'Read more',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
