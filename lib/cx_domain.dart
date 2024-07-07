enum CXDomain {
  eu1,
  eu2,
  us1,
  us2,
  ap1,
  ap2,
}

extension CoralogixDomainExtension on CXDomain {
  String get url {
    switch (this) {
      case CXDomain.eu1:
        return 'https://ingress.eu1.rum-ingress-coralogix.com';
      case CXDomain.eu2:
        return 'https://ingress.eu2.rum-ingress-coralogix.com';
      case CXDomain.us1:
        return 'https://ingress.us1.rum-ingress-coralogix.com';
      case CXDomain.us2:
        return 'https://ingress.us2.rum-ingress-coralogix.com';
      case CXDomain.ap1:
        return 'https://ingress.ap1.rum-ingress-coralogix.com';
      case CXDomain.ap2:
        return 'https://ingress.ap2.rum-ingress-coralogix.com';
    }
  }

  String get stringValue {
    switch (this) {
      case CXDomain.eu1:
        return 'EU1';
      case CXDomain.eu2:
        return 'EU2';
      case CXDomain.us1:
        return 'US1';
      case CXDomain.us2:
        return 'US2';
      case CXDomain.ap1:
        return 'AP1';
      case CXDomain.ap2:
        return 'AP2';
    }
  }
}