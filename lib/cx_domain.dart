enum CXDomain {
  EU1,
  EU2,
  US1,
  US2,
  AP1,
  AP2,
}

extension CoralogixDomainExtension on CXDomain {
  String get url {
    switch (this) {
      case CXDomain.EU1:
        return 'https://ingress.eu1.rum-ingress-coralogix.com';
      case CXDomain.EU2:
        return 'https://ingress.eu2.rum-ingress-coralogix.com';
      case CXDomain.US1:
        return 'https://ingress.us1.rum-ingress-coralogix.com';
      case CXDomain.US2:
        return 'https://ingress.us2.rum-ingress-coralogix.com';
      case CXDomain.AP1:
        return 'https://ingress.ap1.rum-ingress-coralogix.com';
      case CXDomain.AP2:
        return 'https://ingress.ap2.rum-ingress-coralogix.com';
    }
  }

  String get stringValue {
    switch (this) {
      case CXDomain.EU1:
        return 'EU1';
      case CXDomain.EU2:
        return 'EU2';
      case CXDomain.US1:
        return 'US1';
      case CXDomain.US2:
        return 'US2';
      case CXDomain.AP1:
        return 'AP1';
      case CXDomain.AP2:
        return 'AP2';
    }
  }
}