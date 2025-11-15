class CitiesData {
  static const Map<String, List<String>> citiesByCountry = {
    'Pakistan': [
      'Karachi',
      'Lahore',
      'Islamabad',
      'Rawalpindi',
      'Faisalabad',
      'Multan',
      'Peshawar',
      'Quetta',
      'Sialkot',
      'Gujranwala',
      'Hyderabad',
      'Sukkur',
      'Larkana',
      'Nawabshah',
      'Mardan',
      'Mingora',
      'Chiniot',
      'Sheikhupura',
      'Rahim Yar Khan',
      'Gujrat',
    ],
    'India': [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Hyderabad',
      'Ahmedabad',
      'Chennai',
      'Kolkata',
      'Surat',
      'Pune',
      'Jaipur',
      'Lucknow',
      'Kanpur',
      'Nagpur',
      'Indore',
      'Thane',
      'Bhopal',
      'Visakhapatnam',
      'Pimpri-Chinchwad',
      'Patna',
      'Vadodara',
    ],
    'United States': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'Philadelphia',
      'San Antonio',
      'San Diego',
      'Dallas',
      'San Jose',
      'Austin',
      'Jacksonville',
      'Fort Worth',
      'Columbus',
      'Charlotte',
      'San Francisco',
      'Indianapolis',
      'Seattle',
      'Denver',
      'Washington',
    ],
    'United Kingdom': [
      'London',
      'Birmingham',
      'Manchester',
      'Glasgow',
      'Liverpool',
      'Leeds',
      'Sheffield',
      'Edinburgh',
      'Bristol',
      'Cardiff',
      'Belfast',
      'Leicester',
      'Wakefield',
      'Coventry',
      'Nottingham',
      'Bradford',
      'Newcastle upon Tyne',
      'Hull',
      'Plymouth',
      'Stoke-on-Trent',
    ],
    'Canada': [
      'Toronto',
      'Montreal',
      'Vancouver',
      'Calgary',
      'Edmonton',
      'Ottawa',
      'Winnipeg',
      'Quebec City',
      'Hamilton',
      'Kitchener',
      'London',
      'Victoria',
      'Halifax',
      'Oshawa',
      'Windsor',
      'Saskatoon',
      'Regina',
      'Sherbrooke',
      'Kelowna',
      'Barrie',
    ],
    'Australia': [
      'Sydney',
      'Melbourne',
      'Brisbane',
      'Perth',
      'Adelaide',
      'Gold Coast',
      'Newcastle',
      'Canberra',
      'Sunshine Coast',
      'Wollongong',
      'Hobart',
      'Geelong',
      'Townsville',
      'Cairns',
      'Darwin',
      'Toowoomba',
      'Ballarat',
      'Bendigo',
      'Albury',
      'Launceston',
    ],
    'Germany': [
      'Berlin',
      'Hamburg',
      'Munich',
      'Cologne',
      'Frankfurt',
      'Stuttgart',
      'Düsseldorf',
      'Dortmund',
      'Essen',
      'Leipzig',
      'Bremen',
      'Dresden',
      'Hannover',
      'Nuremberg',
      'Duisburg',
      'Bochum',
      'Wuppertal',
      'Bielefeld',
      'Bonn',
      'Münster',
    ],
    'France': [
      'Paris',
      'Marseille',
      'Lyon',
      'Toulouse',
      'Nice',
      'Nantes',
      'Strasbourg',
      'Montpellier',
      'Bordeaux',
      'Lille',
      'Rennes',
      'Reims',
      'Le Havre',
      'Saint-Étienne',
      'Toulon',
      'Grenoble',
      'Dijon',
      'Angers',
      'Nîmes',
      'Villeurbanne',
    ],
    'China': [
      'Shanghai',
      'Beijing',
      'Chongqing',
      'Tianjin',
      'Guangzhou',
      'Shenzhen',
      'Wuhan',
      'Dongguan',
      'Chengdu',
      'Nanjing',
      'Xi\'an',
      'Shenyang',
      'Hangzhou',
      'Foshan',
      'Harbin',
      'Qingdao',
      'Suzhou',
      'Dalian',
      'Zhengzhou',
      'Shantou',
    ],
    'Japan': [
      'Tokyo',
      'Yokohama',
      'Osaka',
      'Nagoya',
      'Sapporo',
      'Fukuoka',
      'Kobe',
      'Kawasaki',
      'Kyoto',
      'Saitama',
      'Hiroshima',
      'Sendai',
      'Kitakyushu',
      'Chiba',
      'Sakai',
      'Niigata',
      'Hamamatsu',
      'Okayama',
      'Sagamihara',
      'Kumamoto',
    ],
  };

  static List<String> getCitiesForCountry(String countryName) {
    return citiesByCountry[countryName] ?? [];
  }

  static List<String> getCitiesForCountryAndState(
      String countryName, String? stateName) {
    if (stateName == null) {
      return getCitiesForCountry(countryName);
    }

    // For now, we'll return a subset of cities based on state
    // In a real app, you'd have a comprehensive database with state-city mapping
    final allCities = getCitiesForCountry(countryName);

    // Simple state-based filtering for major countries
    switch (countryName.toLowerCase()) {
      case 'pakistan':
        return _getPakistaniCitiesByState(stateName, allCities);
      case 'united states':
      case 'usa':
        return _getUSCitiesByState(stateName, allCities);
      case 'canada':
        return _getCanadianCitiesByState(stateName, allCities);
      case 'india':
        return _getIndianCitiesByState(stateName, allCities);
      default:
        return allCities; // Return all cities if no state filtering available
    }
  }

  static List<String> _getUSCitiesByState(
      String state, List<String> allCities) {
    // Simplified mapping - in reality you'd have a comprehensive database
    switch (state.toLowerCase()) {
      case 'california':
        return [
          'Los Angeles',
          'San Francisco',
          'San Diego',
          'San Jose',
          'Fresno',
          'Sacramento'
        ];
      case 'new york':
        return [
          'New York',
          'Buffalo',
          'Rochester',
          'Yonkers',
          'Syracuse',
          'Albany'
        ];
      case 'texas':
        return [
          'Houston',
          'San Antonio',
          'Dallas',
          'Austin',
          'Fort Worth',
          'El Paso'
        ];
      case 'florida':
        return [
          'Jacksonville',
          'Miami',
          'Tampa',
          'Orlando',
          'St. Petersburg',
          'Hialeah'
        ];
      case 'illinois':
        return [
          'Chicago',
          'Aurora',
          'Rockford',
          'Joliet',
          'Naperville',
          'Springfield'
        ];
      default:
        return allCities
            .take(10)
            .toList(); // Return first 10 cities as fallback
    }
  }

  static List<String> _getCanadianCitiesByState(
      String state, List<String> allCities) {
    switch (state.toLowerCase()) {
      case 'ontario':
        return [
          'Toronto',
          'Ottawa',
          'Hamilton',
          'London',
          'Kitchener',
          'Windsor'
        ];
      case 'quebec':
        return [
          'Montreal',
          'Quebec City',
          'Laval',
          'Gatineau',
          'Longueuil',
          'Sherbrooke'
        ];
      case 'british columbia':
        return [
          'Vancouver',
          'Victoria',
          'Surrey',
          'Burnaby',
          'Richmond',
          'Abbotsford'
        ];
      case 'alberta':
        return [
          'Calgary',
          'Edmonton',
          'Red Deer',
          'Lethbridge',
          'St. Albert',
          'Medicine Hat'
        ];
      default:
        return allCities.take(10).toList();
    }
  }

  static List<String> _getIndianCitiesByState(
      String state, List<String> allCities) {
    switch (state.toLowerCase()) {
      case 'maharashtra':
        return ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Solapur'];
      case 'karnataka':
        return [
          'Bangalore',
          'Mysore',
          'Hubli',
          'Mangalore',
          'Belgaum',
          'Gulbarga'
        ];
      case 'tamil nadu':
        return [
          'Chennai',
          'Coimbatore',
          'Madurai',
          'Tiruchirappalli',
          'Salem',
          'Tirunelveli'
        ];
      case 'gujarat':
        return [
          'Ahmedabad',
          'Surat',
          'Vadodara',
          'Rajkot',
          'Bhavnagar',
          'Jamnagar'
        ];
      case 'west bengal':
        return [
          'Kolkata',
          'Asansol',
          'Siliguri',
          'Durgapur',
          'Bardhaman',
          'Malda'
        ];
      default:
        return allCities.take(10).toList();
    }
  }

  static List<String> _getPakistaniCitiesByState(
      String state, List<String> allCities) {
    switch (state.toLowerCase()) {
      case 'sindh':
        return [
          'Karachi',
          'Hyderabad',
          'Sukkur',
          'Larkana',
          'Nawabshah',
          'Mirpur Khas',
          'Jacobabad',
          'Shikarpur'
        ];
      case 'punjab':
        return [
          'Lahore',
          'Faisalabad',
          'Rawalpindi',
          'Multan',
          'Gujranwala',
          'Sialkot',
          'Sargodha',
          'Bahawalpur',
          'Sahiwal',
          'Jhang'
        ];
      case 'khyber pakhtunkhwa (kpk)':
      case 'kpk':
        return [
          'Peshawar',
          'Mardan',
          'Mingora',
          'Kohat',
          'Abbottabad',
          'Dera Ismail Khan',
          'Mansehra',
          'Bannu'
        ];
      case 'balochistan':
        return [
          'Quetta',
          'Turbat',
          'Chaman',
          'Zhob',
          'Gwadar',
          'Dera Bugti',
          'Khuzdar',
          'Sibi'
        ];
      case 'gilgit-baltistan':
        return [
          'Gilgit',
          'Skardu',
          'Chilas',
          'Astore',
          'Ghanche',
          'Hunza',
          'Nagar'
        ];
      case 'azad jammu and kashmir':
        return [
          'Muzaffarabad',
          'Mirpur',
          'Kotli',
          'Rawalakot',
          'Bhimber',
          'Bagh'
        ];
      case 'islamabad capital territory':
        return ['Islamabad', 'Rawalpindi'];
      default:
        return allCities.take(10).toList();
    }
  }

  static List<String> getAllCountries() {
    return citiesByCountry.keys.toList()..sort();
  }
}
