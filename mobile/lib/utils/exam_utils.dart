const Map<String, String> examDisplayNames = {
  'CA_FND': 'CA Foundation',
  'CA_INT': 'CA Intermediate',
  'CA_FIN': 'CA Final',
  'CS_EXEC': 'CS Executive',
  'CMA_FND': 'CMA Foundation',
  'CFA_L1': 'CFA Level 1',
  'JEE_MAIN': 'JEE Main',
  'JEE_ADV': 'JEE Advanced',
  'NEET_UG': 'NEET UG',
};

String getExamDisplayName(String code) {
  return examDisplayNames[code] ?? code;
}
