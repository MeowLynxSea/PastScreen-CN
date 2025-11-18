# PastScreen — contexte projet

## Résumé
- App macOS 14+ ultra-rapide de capture d'écran orientée développeurs, résidant dans la barre de menus (icône seule, `LSUIElement = YES`), qui envoie chaque capture au presse-papier (PNG + chemin) et, si souhaité, la stocke sur disque.
- Version 1.7 « Launch at Login + polish » : ajout du lancement automatique au démarrage du Mac, corrections du flux onboarding et des calculs de géométrie de capture.
- Historique : v1.6 apportait les conversions ScreenCaptureKit multi-écran fiabilisées et le clipboard "context-aware".
- Développement quotidien sur `PastScreen-dev` (privé), publication publique/Sparkle sur `PastScreen`.

## Stack & Architecture
- Swift 5.9, AppKit + SwiftUI (AppKit pour menu bar/overlays, SwiftUI pour préférences/onboarding).
- Entrée `PastScreenApp` (SwiftUI `App`) → `AppDelegate` (menu bar, Sparkle, hotkey global, services).
- Services principaux :
  - `ScreenshotService` : overlay multi-écran (« Liquid Glass »), capture ScreenCaptureKit/CG, gestion clipboard + fichiers, notifications custom.
  - `PermissionManager` : vérifie/demande Screen Recording, Accessibility, Notifications (flux onboarding).
  - `ScreenshotIntentBridge` : relie App Intents / Shortcuts aux services natifs.
  - `LaunchAtLoginManager` : gère le lancement automatique au démarrage (ServiceManagement, macOS 13+).
- Modèle : `AppSettings` (`@AppStorage`, préférences capture, format, dossier, hotkey, dock, etc.).
- Vues SwiftUI : `SettingsView`, `OnboardingView`, `SelectionWindow` (AppKit), `CustomNotificationView`, `DynamicIslandView`.
- App Intents (`PastScreen/AppIntents`) pour captures zone/plein écran (Siri/Shortcuts/Automation).

## Flux de capture
1. Déclencheur (menu, hotkey ⌥⌘S, App Intent) via `AppDelegate`.
2. `SelectionWindow` couvre tous les écrans, gère les événements souris, récupère les window IDs à exclure.
3. `ScreenshotService` capture avec ScreenCaptureKit (`SCContentFilter` + `SCScreenshotManager`) → CGImage haute résolution.
4. Copie presse-papier intelligente selon app frontmost (image, chemin, ou les deux). Sauvegarde sur disque (timestamp, format PNG/JPEG).
5. Notification UN + pastille « Saved » (DynamicIsland-like) + action « Reveal in Finder ».

## Permissions & livrables
- Permissions requises : Screen Recording (capture), Accessibility (raccourci global), Notifications.
- Entitlements définis dans `PastScreen.entitlements`. Pas d’upload de données.
- Sparkle 2.8 pour auto-update (clés EdDSA, feed `appcast.xml`).

## Workflow release (automatisé via `scripts/package_release.sh`)
- Incrément version/build dans Xcode + Info.plist → Archive → Export app → Notarization + Staple.
- Script automatique : `./scripts/package_release.sh ~/Desktop/PastScreen.app ~/Desktop/PastScreen`
  - Crée le ZIP avec `ditto`, signe avec Sparkle (`sign_update`), met à jour `appcast.xml`.
- Publier GitHub Release via `gh release create` (tag `vX.Y`, upload zip, notes).
- Push vers `public` (distribution) et `origin` (dev) + vérifier feed Sparkle.

## Points d'attention actuels
- Pas (encore) de tests automatisés ; validation manuelle (hotkey, multi-écrans, permissions, clipboard, launch at login).
- Notifications UN only (migration complète depuis `NSUserNotification` vérifiée et fonctionnelle).
- Sons/ressources doivent être présents dans `Assets.xcassets`.
- Mode Dock/Accessory : toggle via préférences, exige refresh de policy.
- Launch at Login : utilise ServiceManagement (macOS 13+), préférence persistée dans UserDefaults.
- Observations 1.7 : flux onboarding corrigé, géométrie de capture stabilisée. ScreenCaptureKit peut capturer quelques pixels de plus que `⇧⌘4` (comportement accepté pour la précision).

## Idées futures
1. Tests UI automatisés (UITest) pour onboarding/preferences.
2. Feedback plus riche (Live Activities, `UNNotificationContentExtension`).
3. Documentation détaillée des services/components pour onboarding contributeurs.
4. Optimisation de la détection app frontmost (catégories) + configuration via UI.
