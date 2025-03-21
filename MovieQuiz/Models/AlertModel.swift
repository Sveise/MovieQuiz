import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    let completion: () -> Void
}
