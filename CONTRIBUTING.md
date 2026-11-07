# Contributing to Ladrones de Banco

**English** · [Español](CONTRIBUTING.es.md)

Contributions are welcome: bug reports, ideas and pull requests. Thanks for helping!

## Report a bug or suggest an idea

Open an [issue](../../issues) describing what happened, or what you'd like the app to do. For bugs, include:

- your iPhone model and iOS version,
- the steps to reproduce it,
- what you expected and what happened instead (a screenshot helps).

## Send a change

1. **Fork** the repository and create a branch from `main`, for example `feature/whatsapp-reminder` or `fix/reminder-date`.
2. **Make your change**, following the existing code style:
   - The code and its identifiers are in Spanish (`Persona`, `saldo`, `Recordatorios`…). Keep it that way.
   - The interface text is in Spanish.
   - Use SwiftUI and SwiftData only, with no third-party dependencies.
3. **Keep the simulator in sync.** If you change a screen, update [`simulador/index.html`](simulador/index.html) too, so the web replica keeps matching the app.
4. **Check that it compiles.** Push your branch: the **Compilar IPA** GitHub Actions workflow runs on your fork and must finish green, which proves the Swift code compiles and the app includes its executable. On a Mac you can also run `bash compilar-ipa.sh`.
5. **Open a pull request** against `main`. Explain what it changes and why, and add a screenshot if the interface changes.

## Commit messages

Write a short title in English, in the imperative, with no body:

```
Add WhatsApp reminder button
```

## Ideas waiting for someone

- Send the collection reminder through WhatsApp with the amount.
- Record what *you* owe, not just what others owe you.
- Due dates per debt.
- Take the profile photo with the camera.
- Statistics, or exporting to Excel.

## License

By contributing, you agree that your code is released under the project's [MIT License](LICENSE). Don't add images or other material you don't have the rights to share.
