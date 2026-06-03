import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let name = application.localizedDisplayName ?? "cette app"
        return makeConfig(appName: name)
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfig(appName: webDomain.domain ?? "ce site")
    }

    // MARK: -

    private func makeConfig(appName: String) -> ShieldConfiguration {
        let indigo = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1)
        let icon   = UIImage(systemName: "pause.circle.fill")?
            .withTintColor(indigo, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 10/255, green: 10/255, blue: 15/255, alpha: 0.97),
            icon: icon,
            title: ShieldConfiguration.Label(
                text: "Pause intentionnelle",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tu allais ouvrir \(appName).\nPrends un instant.",
                color: UIColor(white: 1, alpha: 0.55)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Non merci",
                color: .white
            ),
            primaryButtonBackgroundColor: indigo,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Ouvrir quand même",
                color: UIColor(white: 1, alpha: 0.4)
            )
        )
    }
}
