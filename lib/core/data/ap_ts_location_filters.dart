// === Andhra Pradesh & Telangana — state / city lists for partner filters ===

const String kAllStatesLabel = 'All states';
const String kAllCitiesLabel = 'All cities';

const List<String> kPartnerStateOptions = [
  kAllStatesLabel,
  'Andhra Pradesh',
  'Telangana',
];

/// Cities shown when a state is selected (plus [kAllCitiesLabel] as first option in UI).
const List<String> kAndhraPradeshCities = [
  'Visakhapatnam',
  'Vijayawada',
  'Guntur',
  'Nellore',
  'Kurnool',
  'Tirupati',
  'Rajahmundry',
  'Kakinada',
  'Kadapa',
  'Anantapur',
  'Eluru',
  'Ongole',
  'Nandyal',
  'Machilipatnam',
  'Adoni',
  'Tenali',
  'Chittoor',
  'Hindupur',
  'Proddatur',
  'Bhimavaram',
  'Madanapalle',
  'Guntakal',
  'Dharmavaram',
  'Gudivada',
  'Narasaraopet',
  'Tadipatri',
  'Chilakaluripet',
];

const List<String> kTelanganaCities = [
  'Hyderabad',
  'Warangal',
  'Nizamabad',
  'Karimnagar',
  'Ramagundam',
  'Khammam',
  'Mahbubnagar',
  'Nalgonda',
  'Adilabad',
  'Suryapet',
  'Miryalaguda',
  'Siddipet',
  'Jagtial',
  'Mancherial',
  'Peddapalli',
  'Kamareddy',
  'Bodhan',
  'Huzurabad',
  'Gadwal',
  'Wanaparthy',
  'Nirmal',
  'Bellampalle',
  'Bhongir',
  'Vikarabad',
  'Medak',
];

List<String> citiesForPartnerState(String? state) {
  if (state == null || state.isEmpty || state == kAllStatesLabel) {
    return [kAllCitiesLabel];
  }
  switch (state) {
    case 'Andhra Pradesh':
      return [kAllCitiesLabel, ...kAndhraPradeshCities];
    case 'Telangana':
      return [kAllCitiesLabel, ...kTelanganaCities];
    default:
      return [kAllCitiesLabel];
  }
}

/// Whether [locationOrAddress] matches selected state/city (case-insensitive substring match).
bool vendorMatchesLocationFilter({
  required String location,
  required String address,
  String? selectedState,
  String? selectedCity,
}) {
  final blob = '$location $address'.toLowerCase().trim();
  if (blob.isEmpty) return false;

  final state = selectedState;
  final city = selectedCity;

  if (state == null || state.isEmpty || state == kAllStatesLabel) {
    if (city == null || city.isEmpty || city == kAllCitiesLabel) {
      return true;
    }
    return blob.contains(city.toLowerCase());
  }

  if (!_matchesState(blob, state)) {
    return false;
  }

  if (city == null || city.isEmpty || city == kAllCitiesLabel) {
    return true;
  }

  return blob.contains(city.toLowerCase());
}

bool _matchesState(String blob, String state) {
  switch (state) {
    case 'Andhra Pradesh':
      if (blob.contains('andhra pradesh') ||
          blob.contains('andhra,') ||
          blob.contains(' a.p.') ||
          blob.contains(' ap,') ||
          blob.contains(', ap') ||
          blob.endsWith(' ap')) {
        return true;
      }
      for (final c in kAndhraPradeshCities) {
        if (blob.contains(c.toLowerCase())) return true;
      }
      return false;
    case 'Telangana':
      if (blob.contains('telangana')) return true;
      for (final c in kTelanganaCities) {
        if (blob.contains(c.toLowerCase())) return true;
      }
      return false;
    default:
      return true;
  }
}
