# 🚀 Guide de Release - PastScreen

Guide complet pour créer une nouvelle release avec mises à jour automatiques Sparkle.

---

## 📋 Checklist Pré-Release

- [ ] Tous les changements commités sur `PastScreen-dev`
- [ ] Tests manuels effectués
- [ ] Version incrémentée dans Xcode
- [ ] Changelog préparé

---

## 🔢 Étape 1: Incrémenter la Version

### Dans Xcode

1. Ouvrir `PastScreen.xcodeproj`
2. Sélectionner le **target PastScreen**
3. Onglet **General**
4. Modifier:
   - **Version**: `1.4` → `1.5` (par exemple)
   - **Build**: `7` → `8` (auto-incrémenté ou manuel)

### Vérifier Info.plist

Les valeurs doivent correspondre:
```xml
<key>CFBundleShortVersionString</key>
<string>1.5</string>
<key>CFBundleVersion</key>
<string>8</string>
```

---

## 📦 Étape 2: Créer l'Archive Xcode

### Dans Xcode

1. **Product → Destination → Any Mac**
2. **Product → Clean Build Folder** (⌘⇧K)
3. **Product → Archive**
4. Attendre la création de l'archive

### Dans Organizer

1. La fenêtre **Organizer** s'ouvre automatiquement
2. Sélectionner l'archive **PastScreen**
3. Cliquer **Distribute App**
4. Choisir **Copy App**
5. Sélectionner un dossier de destination (ex: `~/Desktop/PastScreen-Release`)
6. Cliquer **Export**

**Résultat**: `PastScreen.app` exportée dans le dossier choisi

---

## 🗜️ Étape 3: Créer et Signer le .zip

### Commandes Terminal

```bash
# 1. Aller dans le dossier d'export
cd ~/Desktop/PastScreen-Release

# 2. Vérifier que l'app existe
ls -la PastScreen.app

# 3. Créer le .zip (structure Sparkle)
ditto -c -k --sequesterRsrc --keepParent PastScreen.app PastScreen-1.5.zip

# 4. Signer le .zip avec Sparkle
~/Library/Developer/Xcode/DerivedData/ScreenSnap-*/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update PastScreen-1.5.zip

# 5. Obtenir la taille du fichier
ls -l PastScreen-1.5.zip
```

### Informations à Noter

La commande `sign_update` affiche:
```
sparkle:edSignature="XXXXXX..." length="YYYYYY"
```

**Notez**:
- ✅ **Signature EdDSA**: `XXXXXX...`
- ✅ **Taille en octets**: `YYYYYY`

---

## 🌐 Étape 4: Créer la GitHub Release

### Via Interface Web (Recommandé)

1. Aller sur: https://github.com/augiefra/PastScreen/releases/new

2. Remplir le formulaire:
   - **Tag**: `v1.5`
   - **Release title**: `PastScreen 1.5 - [Titre Descriptif]`
   - **Description**: Copier le template ci-dessous

3. **Uploader le fichier**:
   - Glisser `PastScreen-1.5.zip` dans la zone "Attach binaries"

4. Cliquer **Publish release**

### Template Description

```markdown
## 🎉 PastScreen 1.5 - [Titre Descriptif]

### ✨ What's New
- [Feature 1]
- [Feature 2]
- [Improvement 1]

### 🐛 Bug Fixes
- [Fix 1]
- [Fix 2]

### 📦 Download
Download **PastScreen-1.5.zip** below

### 🔧 Requirements
- macOS 14.0 (Sonoma) or later

### 📝 Full Changelog
See full changes: [v1.4...v1.5](https://github.com/augiefra/PastScreen/compare/v1.4...v1.5)
```

### Via CLI (Optionnel)

```bash
cd ~/Desktop/PastScreen-Release

gh release create v1.5 \
  --title "PastScreen 1.5 - [Titre]" \
  --notes "[Description]" \
  PastScreen-1.5.zip
```

---

## 📄 Étape 5: Mettre à Jour appcast.xml

### Dans le Projet

1. Ouvrir `/Users/ecologni/Desktop/Clemadel/PastScreen/appcast.xml`

2. Ajouter le nouvel `<item>` **EN HAUT** (avant v1.4):

```xml
    <item>
      <title>Version 1.5</title>
      <description><![CDATA[
        <h2>PastScreen 1.5 - [Titre]</h2>
        <ul>
          <li><strong>[Feature]:</strong> Description</li>
          <li><strong>[Improvement]:</strong> Description</li>
          <li><strong>[Bug Fix]:</strong> Description</li>
        </ul>
      ]]></description>
      <pubDate>Mon, 18 Nov 2024 10:00:00 +0100</pubDate>
      <sparkle:version>8</sparkle:version>
      <sparkle:shortVersionString>1.5</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <enclosure
        url="https://github.com/augiefra/PastScreen/releases/download/v1.5/PastScreen-1.5.zip"
        sparkle:edSignature="[SIGNATURE_ETAPE_3]"
        length="[TAILLE_ETAPE_3]"
        type="application/octet-stream" />
    </item>
```

### Valeurs à Remplacer

- `[Titre]`: Titre de la release
- `[Feature/Improvement/Bug Fix]`: Changements
- `Mon, 18 Nov 2024 10:00:00 +0100`: Date actuelle au format RFC 2822
- `8`: Nouveau numéro de build (CFBundleVersion)
- `1.5`: Nouvelle version (CFBundleShortVersionString)
- `v1.5`: Tag de la release GitHub
- `[SIGNATURE_ETAPE_3]`: Signature obtenue à l'étape 3
- `[TAILLE_ETAPE_3]`: Taille en octets obtenue à l'étape 3

---

## 🚀 Étape 6: Publier sur GitHub

### Commandes Git

```bash
cd /Users/ecologni/Desktop/Clemadel/PastScreen

# 1. Vérifier les changements
git status

# 2. Ajouter appcast.xml
git add appcast.xml

# 3. Commit
git commit -m "release: PastScreen v1.5"

# 4. Push vers dev (optionnel, pour historique)
git push origin main

# 5. Push vers PUBLIC (IMPORTANT!)
git push public main
```

---

## ✅ Étape 7: Vérification

### Vérifier appcast.xml en ligne

Ouvrir dans le navigateur:
```
https://raw.githubusercontent.com/augiefra/PastScreen/main/appcast.xml
```

**Vérifier**:
- ✅ Version 1.5 apparaît en premier
- ✅ Signature correcte
- ✅ Taille correcte
- ✅ URL GitHub correcte

### Vérifier la Release GitHub

Aller sur:
```
https://github.com/augiefra/PastScreen/releases
```

**Vérifier**:
- ✅ Release v1.5 visible
- ✅ Fichier PastScreen-1.5.zip téléchargeable
- ✅ Description complète

---

## 🧪 Étape 8: Tester les Mises à Jour

### Test Local

1. Installer PastScreen v1.4 sur une autre machine (ou VM)
2. Lancer l'app
3. **Sparkle → Check for Updates**
4. Vérifier que v1.5 est détectée
5. Tester l'installation

### Logs Sparkle (Si Problème)

```bash
# Voir les logs système
log stream --predicate 'subsystem == "org.sparkle-project.Sparkle"' --level debug
```

---

## 🔧 Outils et Chemins Importants

### Clés Sparkle

**Clé publique** (dans Info.plist):
```
0kgGfpfzDCMIcKXLqaNbUM+p14CHFGib3GqG3FtCOSk=
```

**Clé privée**: Stockée dans le Keychain macOS

### Outils Sparkle

```bash
# Generate keys (si besoin de nouvelles clés)
~/Library/Developer/Xcode/DerivedData/ScreenSnap-*/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_keys

# Sign update
~/Library/Developer/Xcode/DerivedData/ScreenSnap-*/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update
```

### Repos Git

```bash
# Dev (privé)
origin: https://github.com/augiefra/PastScreen-dev.git

# Public
public: https://github.com/augiefra/PastScreen.git
```

---

## 📅 Format de Date RFC 2822

Pour `<pubDate>` dans appcast.xml:

```bash
# Générer la date actuelle au bon format
date '+%a, %d %b %Y %H:%M:%S %z'
```

Exemple: `Mon, 18 Nov 2024 10:00:00 +0100`

---

## ❌ Erreurs Communes

### Signature Invalide
- **Cause**: Mauvaise signature dans appcast.xml
- **Solution**: Re-signer le .zip avec `sign_update`

### Taille Incorrecte
- **Cause**: Taille du fichier ne correspond pas
- **Solution**: Vérifier avec `ls -l PastScreen-1.5.zip`

### URL 404
- **Cause**: Release GitHub pas publiée ou mauvais tag
- **Solution**: Vérifier le tag dans l'URL (v1.5 vs 1.5)

### Mise à Jour Non Détectée
- **Cause**: appcast.xml pas à jour sur GitHub
- **Solution**: Vérifier `git push public main`

---

## 📝 Checklist Post-Release

- [ ] appcast.xml en ligne vérifié
- [ ] Release GitHub publiée et fichier téléchargeable
- [ ] Test de mise à jour effectué
- [ ] Version dev incrémentée pour prochaine release
- [ ] Changelog documenté

---

## 🎯 Résumé Rapide (Aide-Mémoire)

```bash
# 1. Xcode: Version 1.5, Build 8
# 2. Product → Archive → Export
cd ~/Desktop/PastScreen-Release

# 3. Créer et signer
ditto -c -k --sequesterRsrc --keepParent PastScreen.app PastScreen-1.5.zip
~/Library/Developer/Xcode/DerivedData/ScreenSnap-*/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update PastScreen-1.5.zip
# → Noter signature + taille

# 4. GitHub Release: v1.5 + upload .zip

# 5. Update appcast.xml avec signature + taille

# 6. Push
cd /Users/ecologni/Desktop/Clemadel/PastScreen
git add appcast.xml
git commit -m "release: PastScreen v1.5"
git push public main

# 7. Vérifier: https://raw.githubusercontent.com/augiefra/PastScreen/main/appcast.xml
```

---

**Durée estimée**: 15-20 minutes par release

**Fréquence recommandée**: Selon les besoins, mais tester Sparkle avant chaque release publique
