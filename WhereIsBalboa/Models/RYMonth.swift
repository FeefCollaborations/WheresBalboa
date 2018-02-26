import Foundation

enum RYMonth {
    case mar17, apr17, may17, jun17, jul17, aug17, sep17, oct17, nov17, dec17, jan18, feb18
    
    var dateInterval: DateInterval {
        switch self {
            case .mar17:
                return DateInterval("05/03/2017" + DateInterval.delimiterString + "01/04/2017")!
            case .apr17:
                return DateInterval("01/04/2017" + DateInterval.delimiterString + "29/04/2017")!
            case .may17:
                return DateInterval("29/04/2017" + DateInterval.delimiterString + "27/05/2017")!
            case .jun17:
                return DateInterval("27/05/2017" + DateInterval.delimiterString + "01/06/2017")!
            case .jul17:
                return DateInterval("01/06/2017" + DateInterval.delimiterString + "29/07/2017")!
            case .aug17:
                return DateInterval("29/07/2017" + DateInterval.delimiterString + "26/08/2017")!
            case .sep17:
                return DateInterval("26/08/2017" + DateInterval.delimiterString + "30/09/2017")!
            case .oct17:
                return DateInterval("30/09/2017" + DateInterval.delimiterString + "04/11/2017")!
            case .nov17:
                return DateInterval("04/11/2017" + DateInterval.delimiterString + "02/12/2017")!
            case .dec17:
                return DateInterval("02/12/2017" + DateInterval.delimiterString + "30/12/2017")!
            case .jan18:
                return DateInterval("30/12/2017" + DateInterval.delimiterString + "27/01/2018")!
            case .feb18:
                return DateInterval("27/01/2018" + DateInterval.delimiterString + "03/03/2018")!
        }
    }
}
