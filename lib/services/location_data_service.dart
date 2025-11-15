import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationDataService {
  // Using CountriesNow API (Free) - Direct API calls
  static const String _countriesNowApiBase =
      'https://countriesnow.space/api/v0.1';

  static final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 10);

  /// Search for cities by name with country filter using CountriesNow API
  static Future<List<CityData>> searchCities(
    String query, {
    String? countryCode,
    int limit = 20,
  }) async {
    try {
      // Get all cities for the country first
      List<CityData> allCities = [];

      if (countryCode != null && countryCode.isNotEmpty) {
        // Convert country code to country name
        final countryName = _getCountryNameFromCode(countryCode);
        if (countryName != null) {
          print('SearchCities: Getting cities for country: $countryName');
          allCities = await _getCitiesForCountry(countryName);
          print('SearchCities: Got ${allCities.length} cities');
        } else {
          print(
              'SearchCities: Could not find country name for code: $countryCode');
          return [];
        }
      } else {
        // If no country specified, we can't search effectively
        print('SearchCities: No country code provided');
        return [];
      }

      // Filter cities by search query if provided
      if (query.trim().isEmpty) {
        // Return all cities if no query (already sorted by _getCitiesForCountry)
        print(
            'SearchCities: No query, returning all ${allCities.length} cities');
        return allCities;
      } else {
        // Filter cities by search query
        final filteredCities = allCities
            .where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        print(
            'SearchCities: Filtered to ${filteredCities.length} cities matching "$query"');
        return filteredCities;
      }
    } catch (e) {
      print('CountriesNow Search Error: $e');
      throw Exception('Failed to search cities: $e');
    }
  }

  /// Get cities for a specific state in a country using CountriesNow API
  static Future<List<CityData>> getCitiesInState(
    String state,
    String countryCode, {
    int limit = 50,
  }) async {
    try {
      // Convert country code to country name
      final countryName = _getCountryNameFromCode(countryCode);
      if (countryName == null) {
        return [];
      }

      print('Getting cities for state: $state in country: $countryName');
      print('API URL: $_countriesNowApiBase/countries/state/cities');
      print('Request Body: {"country": "$countryName", "state": "$state"}');
      // Use CountriesNow API to get cities for specific state
      // API redirects to GET with query parameters
      final url = Uri.parse('$_countriesNowApiBase/countries/state/cities/q')
          .replace(queryParameters: {
        'country': countryName,
        'state': state,
      });

      print('GET URL: $url');

      final response = await _client.get(url).timeout(_timeout);

      print('Cities API Response Status: ${response.statusCode}');
      print('Cities API Response Headers: ${response.headers}');
      print('Cities API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('ERROR: API request failed with status: ${response.statusCode}');
        print('ERROR: Response body: ${response.body}');
        throw Exception(
            'API request failed with status: ${response.statusCode} - ${response.body}');
      }

      final Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
        print('Parsed JSON data: $data');
      } catch (e) {
        print('ERROR: Failed to parse JSON response: $e');
        print('ERROR: Raw response: ${response.body}');
        throw Exception('Failed to parse API response: $e');
      }

      if (data['error'] == true) {
        final errorMsg = data['msg'] ?? 'Unknown API error';
        print('ERROR: CountriesNow API returned error: $errorMsg');
        throw Exception('CountriesNow API error: $errorMsg');
      }

      final List<dynamic> citiesRaw = data['data'] ?? [];
      print('Fetched ${citiesRaw.length} cities');

      // Convert all cities to CityData objects first
      final List<CityData> cities = citiesRaw.map((cityName) {
        return CityData(
          name: cityName.toString(),
          state: state,
          country: countryName,
          countryCode: countryCode,
          lat: 0.0,
          lon: 0.0,
        );
      }).toList();

      // Sort alphabetically
      cities.sort((a, b) => a.name.compareTo(b.name));

      print(
          'Processed ${cities.length} cities for $state, $countryName (sorted alphabetically)');
      return cities;
    } catch (e) {
      print('CountriesNow Cities in State Error: $e');
      throw Exception('Failed to get cities in state: $e');
    }
  }

  /// Get states/regions for a country using CountriesNow API
  static Future<List<String>> getStatesForCountry(String countryCode) async {
    try {
      // Convert country code to country name
      final countryName = _getCountryNameFromCode(countryCode);
      if (countryName == null) {
        throw Exception('Country not found: $countryCode');
      }

      print('Getting states for country: $countryName using CountriesNow API');
      print('API URL: $_countriesNowApiBase/countries/states (GET request)');

      // Use CountriesNow API to get ALL countries with states, then filter
      final response = await _client
          .get(Uri.parse('$_countriesNowApiBase/countries/states'))
          .timeout(_timeout);

      print('States API Response Status: ${response.statusCode}');
      print('States API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'API request failed with status: ${response.statusCode} - ${response.body}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed states data: $data');

      if (data['error'] == true) {
        final errorMsg = data['msg'] ?? 'Unknown API error';
        print('ERROR: CountriesNow API returned error: $errorMsg');
        throw Exception('CountriesNow API error: $errorMsg');
      }

      // data['data'] is an array of all countries with their states
      final List<dynamic> countriesData = data['data'] ?? [];
      print('Found ${countriesData.length} countries in API response');

      // Find the specific country
      Map<String, dynamic>? targetCountry;
      for (var country in countriesData) {
        if (country is Map && country['name'] == countryName) {
          targetCountry = Map<String, dynamic>.from(country);
          break;
        }
      }

      if (targetCountry == null) {
        print('ERROR: Country "$countryName" not found in API response');
        throw Exception('Country "$countryName" not found');
      }

      print('Found target country: ${targetCountry['name']}');

      // Extract states from the country
      final List<dynamic> statesData = targetCountry['states'] ?? [];
      print('States data for $countryName: $statesData');

      final List<String> states = statesData
          .map((state) {
            if (state is Map) {
              return state['name'].toString().trim();
            } else {
              return state.toString().trim();
            }
          })
          .where((name) => name.isNotEmpty)
          .toList();

      print('Found ${states.length} states for country: $countryName');
      return states;
    } catch (e) {
      print('CountriesNow States Error: $e');
      throw Exception('Failed to get states: $e');
    }
  }

  /// Get all countries using CountriesNow API
  static Future<List<String>> getAllCountries() async {
    try {
      print('Fetching all countries from CountriesNow API');

      final response = await _client
          .get(
            Uri.parse('$_countriesNowApiBase/countries'),
          )
          .timeout(_timeout);

      print('Countries API Response Status: ${response.statusCode}');
      print('Countries API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'API request failed with status: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed countries data: $data');

      if (data['error'] == true) {
        final errorMsg = data['msg'] ?? 'Unknown API error';
        print('ERROR: CountriesNow API returned error: $errorMsg');
        throw Exception('CountriesNow API error: $errorMsg');
      }

      final List<dynamic> countriesData = data['data'] ?? [];
      print('Countries raw data: $countriesData');
      print(
          'First country item: ${countriesData.isNotEmpty ? countriesData[0] : "empty"}');

      final List<String> countries = countriesData
          .map((country) {
            if (country is Map) {
              // If it's a map, try to get 'country' or 'name' field
              return (country['country'] ?? country['name'] ?? '').toString();
            } else {
              // If it's a string, use it directly
              return country.toString();
            }
          })
          .where((name) => name.isNotEmpty)
          .toList();

      print('Found ${countries.length} countries');
      return countries;
    } catch (e) {
      print('CountriesNow Get Countries Error: $e');
      throw Exception('Failed to get countries: $e');
    }
  }

  /// Get cities for a specific country using CountriesNow API
  static Future<List<CityData>> _getCitiesForCountry(String countryName) async {
    try {
      print('Fetching cities for country: $countryName');

      // Use CountriesNow API to get cities for country
      // API redirects to GET with query parameters
      final url = Uri.parse('$_countriesNowApiBase/countries/cities/q')
          .replace(queryParameters: {
        'country': countryName,
      });

      print('GET URL: $url');

      final response = await _client.get(url).timeout(_timeout);

      print('Cities API Response Status: ${response.statusCode}');
      print('Cities API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'API request failed with status: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      print('Parsed cities data: $data');

      if (data['error'] == true) {
        final errorMsg = data['msg'] ?? 'Unknown API error';
        print('ERROR: CountriesNow API returned error: $errorMsg');
        throw Exception('CountriesNow API error: $errorMsg');
      }

      // data['data'] is directly an array of city name strings
      final List<dynamic> citiesRaw = data['data'] ?? [];
      print('Cities raw data count: ${citiesRaw.length}');
      final countryCode = _getCountryCodeFromName(countryName);

      // Convert all cities to CityData objects
      final List<CityData> cities = citiesRaw
          .map((cityName) => CityData(
                name: cityName.toString(),
                state:
                    null, // CountriesNow doesn't provide state information in cities endpoint
                country: countryName,
                countryCode: countryCode,
                lat: 0.0, // CountriesNow doesn't provide coordinates
                lon: 0.0,
              ))
          .toList();

      // Sort alphabetically
      cities.sort((a, b) => a.name.compareTo(b.name));

      print(
          'Successfully fetched and sorted ${cities.length} cities for $countryName');
      return cities;
    } catch (e) {
      print('CountriesNow Get Cities Error: $e');
      throw Exception('Failed to get cities for country: $e');
    }
  }

  /// Convert country code to country name
  static String? _getCountryNameFromCode(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'US':
        return 'United States';
      case 'PK':
        return 'Pakistan';
      case 'IN':
        return 'India';
      case 'CN':
        return 'China';
      case 'GB':
        return 'United Kingdom';
      case 'CA':
        return 'Canada';
      case 'AU':
        return 'Australia';
      case 'DE':
        return 'Germany';
      case 'FR':
        return 'France';
      case 'JP':
        return 'Japan';
      case 'BR':
        return 'Brazil';
      case 'RU':
        return 'Russia';
      case 'IT':
        return 'Italy';
      case 'ES':
        return 'Spain';
      case 'MX':
        return 'Mexico';
      case 'AR':
        return 'Argentina';
      case 'ZA':
        return 'South Africa';
      case 'NG':
        return 'Nigeria';
      case 'EG':
        return 'Egypt';
      case 'BD':
        return 'Bangladesh';
      case 'ID':
        return 'Indonesia';
      case 'PH':
        return 'Philippines';
      case 'TR':
        return 'Turkey';
      case 'TH':
        return 'Thailand';
      case 'VN':
        return 'Vietnam';
      case 'KR':
        return 'South Korea';
      case 'MY':
        return 'Malaysia';
      case 'SG':
        return 'Singapore';
      case 'NL':
        return 'Netherlands';
      case 'BE':
        return 'Belgium';
      case 'CH':
        return 'Switzerland';
      case 'AT':
        return 'Austria';
      case 'SE':
        return 'Sweden';
      case 'NO':
        return 'Norway';
      case 'DK':
        return 'Denmark';
      case 'FI':
        return 'Finland';
      case 'PL':
        return 'Poland';
      case 'CZ':
        return 'Czech Republic';
      case 'HU':
        return 'Hungary';
      case 'GR':
        return 'Greece';
      case 'PT':
        return 'Portugal';
      case 'IE':
        return 'Ireland';
      case 'NZ':
        return 'New Zealand';
      case 'SA':
        return 'Saudi Arabia';
      case 'AE':
        return 'United Arab Emirates';
      case 'IL':
        return 'Israel';
      case 'JO':
        return 'Jordan';
      case 'LB':
        return 'Lebanon';
      case 'KW':
        return 'Kuwait';
      case 'QA':
        return 'Qatar';
      case 'BH':
        return 'Bahrain';
      case 'OM':
        return 'Oman';
      case 'IQ':
        return 'Iraq';
      case 'IR':
        return 'Iran';
      case 'AF':
        return 'Afghanistan';
      case 'LK':
        return 'Sri Lanka';
      case 'NP':
        return 'Nepal';
      case 'BT':
        return 'Bhutan';
      case 'MV':
        return 'Maldives';
      case 'MM':
        return 'Myanmar';
      case 'KH':
        return 'Cambodia';
      case 'LA':
        return 'Laos';
      case 'MN':
        return 'Mongolia';
      case 'KZ':
        return 'Kazakhstan';
      case 'UZ':
        return 'Uzbekistan';
      case 'KG':
        return 'Kyrgyzstan';
      case 'TJ':
        return 'Tajikistan';
      case 'TM':
        return 'Turkmenistan';
      case 'AZ':
        return 'Azerbaijan';
      case 'AM':
        return 'Armenia';
      case 'GE':
        return 'Georgia';
      case 'MD':
        return 'Moldova';
      case 'UA':
        return 'Ukraine';
      case 'BY':
        return 'Belarus';
      case 'LT':
        return 'Lithuania';
      case 'LV':
        return 'Latvia';
      case 'EE':
        return 'Estonia';
      case 'RO':
        return 'Romania';
      case 'BG':
        return 'Bulgaria';
      case 'HR':
        return 'Croatia';
      case 'SI':
        return 'Slovenia';
      case 'SK':
        return 'Slovakia';
      case 'BA':
        return 'Bosnia and Herzegovina';
      case 'RS':
        return 'Serbia';
      case 'ME':
        return 'Montenegro';
      case 'MK':
        return 'North Macedonia';
      case 'AL':
        return 'Albania';
      case 'XK':
        return 'Kosovo';
      case 'CY':
        return 'Cyprus';
      case 'MT':
        return 'Malta';
      case 'IS':
        return 'Iceland';
      case 'LU':
        return 'Luxembourg';
      case 'LI':
        return 'Liechtenstein';
      case 'MC':
        return 'Monaco';
      case 'SM':
        return 'San Marino';
      case 'VA':
        return 'Vatican City';
      case 'AD':
        return 'Andorra';
      case 'CL':
        return 'Chile';
      case 'CO':
        return 'Colombia';
      case 'PE':
        return 'Peru';
      case 'VE':
        return 'Venezuela';
      case 'EC':
        return 'Ecuador';
      case 'BO':
        return 'Bolivia';
      case 'PY':
        return 'Paraguay';
      case 'UY':
        return 'Uruguay';
      case 'GY':
        return 'Guyana';
      case 'SR':
        return 'Suriname';
      case 'FK':
        return 'Falkland Islands';
      case 'GF':
        return 'French Guiana';
      default:
        return null;
    }
  }

  /// Convert country name to country code
  static String _getCountryCodeFromName(String countryName) {
    switch (countryName.toLowerCase()) {
      case 'united states':
        return 'US';
      case 'pakistan':
        return 'PK';
      case 'india':
        return 'IN';
      case 'china':
        return 'CN';
      case 'united kingdom':
        return 'GB';
      case 'canada':
        return 'CA';
      case 'australia':
        return 'AU';
      case 'germany':
        return 'DE';
      case 'france':
        return 'FR';
      case 'japan':
        return 'JP';
      case 'brazil':
        return 'BR';
      case 'russia':
        return 'RU';
      case 'italy':
        return 'IT';
      case 'spain':
        return 'ES';
      case 'mexico':
        return 'MX';
      case 'argentina':
        return 'AR';
      case 'south africa':
        return 'ZA';
      case 'nigeria':
        return 'NG';
      case 'egypt':
        return 'EG';
      case 'bangladesh':
        return 'BD';
      case 'indonesia':
        return 'ID';
      case 'philippines':
        return 'PH';
      case 'turkey':
        return 'TR';
      case 'thailand':
        return 'TH';
      case 'vietnam':
        return 'VN';
      case 'south korea':
        return 'KR';
      case 'malaysia':
        return 'MY';
      case 'singapore':
        return 'SG';
      default:
        return countryName.toUpperCase();
    }
  }

  /// Reverse geocode coordinates to get location details
  static Future<LocationDetails?> reverseGeocode(
    double lat,
    double lon,
  ) async {
    // CountriesNow API doesn't support reverse geocoding
    return null;
  }

  /// Search for a specific location using CountriesNow API
  static Future<List<CityData>> geocodeLocation(String location) async {
    try {
      // CountriesNow API doesn't have direct location search
      // We'll return empty list as it's not supported
      return [];
    } catch (e) {
      throw Exception('Failed to geocode location: $e');
    }
  }

  static void dispose() {
    _client.close();
  }
}

class CityData {
  final String name;
  final String? state;
  final String country;
  final String countryCode;
  final double lat;
  final double lon;

  CityData({
    required this.name,
    this.state,
    required this.country,
    required this.countryCode,
    required this.lat,
    required this.lon,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'] as String? ?? '',
      state: json['state'] as String?,
      country: json['country'] as String? ?? '',
      countryCode: json['country'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayName {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}

class LocationDetails {
  final String name;
  final String? state;
  final String country;
  final String countryCode;
  final double lat;
  final double lon;

  LocationDetails({
    required this.name,
    this.state,
    required this.country,
    required this.countryCode,
    required this.lat,
    required this.lon,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      name: json['name'] as String? ?? '',
      state: json['state'] as String?,
      country: json['country'] as String? ?? '',
      countryCode: json['country'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
