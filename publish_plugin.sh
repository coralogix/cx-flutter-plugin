#!/bin/sh

set -e

echo "🔍 Checking pubspec.yaml for version..."
PLUGIN_VERSION=$(grep '^version: ' pubspec.yaml | awk '{print $2}' | tr -d '\r\n')
if [ -z "$PLUGIN_VERSION" ]; then
  echo "❌ Could not find version in pubspec.yaml"
  exit 1
fi
echo "✅ Version found: $PLUGIN_VERSION"

echo "📖 Verifying CHANGELOG.md contains version..."
if ! grep -Eq "##[[:space:]]*(\[?v?$PLUGIN_VERSION\]?)" CHANGELOG.md; then
  echo "❌ CHANGELOG.md does not contain a version entry for $PLUGIN_VERSION"
  echo "   (Expected something like '## $PLUGIN_VERSION' or '## [v$PLUGIN_VERSION]')"
  exit 1
fi
echo "✅ CHANGELOG.md has an entry for version $PLUGIN_VERSION"

echo "🧪 Running dry-run publish..."
flutter pub publish --dry-run

echo "📦 Validating example project..."
if [ ! -d "example" ]; then
  echo "❌ No example/ directory found"
  exit 1
fi

cd example
flutter clean
flutter pub get

echo "📦 Installing CocoaPods in example/ios..."
cd ios
pod install
cd ..

echo "🚀 Ready to publish version $PLUGIN_VERSION to pub.dev"
echo -n "Are you sure you want to publish? (y/N): "
read confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "❌ Publishing cancelled."
  exit 1
fi

echo "📤 Publishing to pub.dev..."
flutter pub publish --force

echo "🔖 Tagging release with v$PLUGIN_VERSION..."
git tag "v$PLUGIN_VERSION"
git push origin "v$PLUGIN_VERSION"

echo "✅ Plugin version $PLUGIN_VERSION successfully published and tagged!"
