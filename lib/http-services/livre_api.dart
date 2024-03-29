import 'dart:convert';
import 'package:biblio/utils/global_variable.dart';
import 'package:http/http.dart' as http;

import 'package:biblio/models/livreModel.dart';

_setHeaders() =>
    {'Content-type': 'application/json', 'Accept': 'application/json'};

Future<List<LivreModel>> getLivres({String? query}) async {
  String url = urlConnection + "livres";
  List<LivreModel> resultat = [];
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      resultat = List.generate(result['hydra:member'].length, (i) {
        return LivreModel.fromJson(result['hydra:member'][i]);
      });

      if (query != null) {
        switch (query) {
          case "disponible":
            String condition = "oui";
            resultat = resultat
                .where((element) => (element.disponible)
                    .toLowerCase()
                    .contains(condition.toLowerCase()))
                .toList();
            break;
          case "non-disponible":
            String condition = "non";
            resultat = resultat
                .where((element) => (element.disponible)
                    .toLowerCase()
                    .contains(condition.toLowerCase()))
                .toList();
            break;
          default:
            resultat = resultat
                .where((element) => (element.numLivre.toString() +
                        element.design +
                        element.auteur)
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();
        }
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Livres');
    }
  } catch (e) {
    throw "impossible de contacter le server ! Vérifier la connexion!";
  }
  return resultat;
}

Future<void> postLivres(
    String titre, String auteur, DateTime dateEdition) async {
  String url = urlConnection + "livres";
  var data = {
    "design": titre,
    "auteur": auteur,
    "dateEdition": dateEdition.toString(),
    "disponible": "OUI"
  };
  try {
    var response = await http.post(Uri.parse(url),
        body: jsonEncode(data), headers: _setHeaders());
    if (response.statusCode == 201) {
      String responseString = response.body;
      livresFromJson(responseString);
    } else {
      return;
    }
  } catch (e) {
    throw "impossible de contacter le server ! Vérifier la connexion!";
  }
}

Future<void> modifLivres(
    int id, String titre, String auteur, DateTime dateEdition) async {
  String url = urlConnection + "livres/" + id.toString();
  var data = {
    "design": titre,
    "auteur": auteur,
    "dateEdition": dateEdition.toString()
  };
  try {
    var response = await http.put(Uri.parse(url),
        body: jsonEncode(data), headers: _setHeaders());
    if (response.statusCode == 200) {
      String responseString = response.body;
      livresFromJson(responseString);
    } else {
      return;
    }
  } catch (e) {
    throw "impossible de contacter le server ! Vérifier la connexion!";
  }
}

Future<void> deleteLivre(int id) async {
  String url = urlConnection + "livres/" + id.toString();
  try {
    await http.delete(Uri.parse(url));
  } catch (e) {
    throw "impossible de contacter le server ! Vérifier la connexion!";
  }
}
