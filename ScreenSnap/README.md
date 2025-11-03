# ScreenSnap - Application Mac avec Liquid Glass UI

Application macOS 14+ de capture d'écran avec interface Liquid Glass moderne.

## 🚀 Démarrage rapide

### 1. Ouvrir le projet dans Xcode

```bash
open ScreenSnap/ScreenSnap.xcodeproj
```

### 2. Configuration initiale

Dans Xcode :
1. Sélectionnez le projet "ScreenSnap" dans le navigateur
2. Onglet "Signing & Capabilities"
3. Sélectionnez votre **Team** (votre compte développeur Apple)
4. Vérifiez que "Bundle Identifier" est unique (ex: `com.augiefra.ScreenSnap`)

### 3. Configurer les permissions

1. Vérifiez que `Info.plist` est bien lié au target
2. Vérifiez que `ScreenSnap.entitlements` est bien lié au target

Dans "Signing & Capabilities" :
- "App Sandbox" devrait être OFF (déjà configuré dans .entitlements)
- "Hardened Runtime" devrait être activé

### 4. Lancer l'application

Appuyez sur `⌘R` dans Xcode.

Au premier lancement, **macOS demandera les permissions** :
- **Screen Recording** : Aller dans Préférences Système → Sécurité → Confidentialité → Enregistrement d'écran → Cocher "ScreenSnap"
- **Accessibility** (si demandé) : Même chemin → Accessibilité

## 📁 Structure du projet

```
ScreenSnap/
├── Models/
│   └── AppSettings.swift              # Gestion des préférences
├── Services/
│   ├── ScreenshotService.swift         # Capture d'écran basique
│   └── WindowCaptureService.swift      # Capture de fenêtres (ScreenCaptureKit)
├── Views/
│   ├── MenuBarPopoverView.swift        # Popover menu bar
│   └── SettingsView.swift              # Fenêtre de préférences
├── Components/
│   └── LiquidGlassComponents.swift     # Composants UI réutilisables
└── ScreenSnapApp.swift                 # Point d'entrée
```

## ✨ Fonctionnalités implémentées

### ✅ Core Features
- Menu bar app (icône caméra)
- Clic gauche : Popover avec actions rapides
- Clic droit : Menu contextuel
- Capture d'écran avec sélection de zone
- **Capture de fenêtres spécifiques** (liste toutes les apps)
- Copie automatique dans le presse-papiers (⌘V direct)
- Sauvegarde optionnelle sur disque

### 🎨 Design Liquid Glass
- Overlay semi-transparent avec blur
- Labels avec effets visuels
- Animations spring fluides
- UI moderne macOS 14+
- Menu bar popover avec matériaux natifs

### ⚙️ Settings
- Toggle copie clipboard / sauvegarde fichier
- Choix du format (PNG / JPEG)
- Sélection du dossier de sauvegarde
- Options d'affichage

## 🎯 Utilisation

### Capture d'écran standard
1. Clic gauche sur l'icône menu bar (caméra)
2. Cliquer sur "Capture d'écran"
3. Sélectionner la zone en glissant la souris
4. La capture est automatiquement copiée

### Capture de fenêtre
1. Clic gauche sur l'icône menu bar
2. Cliquer sur "Capturer une fenêtre"
3. Choisir l'application/fenêtre dans la liste
4. La fenêtre est capturée automatiquement

### Coller dans un IDE
Après capture, ouvrez votre IDE :
- **VSCode** : `⌘V`
- **Cursor** : `⌘V`
- **Zed** : `⌘V`
- Tout autre app supportant les images

## 🛠️ Prochaines étapes (TODO)

### Phase 1 : Outils d'annotation (priorité haute)
- [ ] Toolbar d'annotation flottant
- [ ] Outil Flèche
- [ ] Outil Blur/Pixelate
- [ ] Outil Texte
- [ ] Outil Highlighter
- [ ] Undo/Redo

### Phase 2 : Raccourcis clavier
- [ ] Intégrer KeyboardShortcuts SPM
- [ ] UI pour définir raccourcis personnalisés
- [ ] Hotkey global pour capture rapide

### Phase 3 : Features avancées
- [ ] Preview/Historique des captures
- [ ] OCR automatique (Vision framework)
- [ ] Détection QR codes
- [ ] Scrolling capture

## 🐛 Troubleshooting

### L'icône n'apparaît pas dans la menu bar
- Vérifiez que `LSUIElement = true` dans Info.plist
- Relancez l'application

### Les permissions sont refusées
- Aller dans Préférences Système → Sécurité → Confidentialité
- Cocher "ScreenSnap" dans "Enregistrement d'écran"
- Redémarrer l'application

### La capture de fenêtre ne fonctionne pas
- Nécessite macOS 12.3+ pour ScreenCaptureKit
- Vérifier les permissions d'enregistrement d'écran
- Certaines fenêtres système ne peuvent pas être capturées (sécurité macOS)

### Erreurs de compilation
- Vérifier que le deployment target est macOS 14.0+
- Vérifier que tous les fichiers sont bien dans le target
- Clean build folder (`⌘⇧K`) puis rebuild

## 📝 Notes de développement

### Frameworks utilisés
- **SwiftUI** : Interface utilisateur moderne
- **AppKit** : Menu bar et fenêtres système
- **ScreenCaptureKit** : Capture de fenêtres (macOS 12.3+)
- **CoreGraphics** : Manipulation d'images
- **UserNotifications** : Notifications modernes

### Architecture
- **MVVM** : Séparation claire modèle/vue
- **Singleton** : AppSettings pour les préférences
- **NotificationCenter** : Communication entre services
- **@AppStorage** : Persistence automatique des settings

### Performance
- Capture optimisée via CGDisplayCreateImage
- Async/await pour ScreenCaptureKit
- Lazy loading des fenêtres disponibles
- Weak references pour éviter les retain cycles

## 📄 Licence

MIT License - Voir LICENSE file

---

Développé avec ❤️ et Claude Code
