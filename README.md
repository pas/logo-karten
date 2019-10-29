# Voraussetzungen
Ruby und Inkscape müssen installiert sein

## Installation Windows
* Installiere Inkscape von `https://inkscape.org/de/release`
* Binde den Pfad zu inkscape als Umgebungsvariable ein. Suche `Umgebungsvariablen bearbeiten` in der Windows-Suche. Klicke auf `Umgebungsvariablen...`. Doppelklicke auf `Systemvariablen`. Drücke auf `Neu` und füge den Pfad zur Datei hinzu. In den meisten Fällen wird es `C:\Program Files\Inkscape` sein.
* Installiere Ruby von `https://rubyinstaller.org/downloads/`
* Suche `cmd.exe` in der Windowssuche und öffne die Konsole
* Installiere nokogiri in der Konsole `gem install nokogiri`
* Wechsle in der Konsole in den Ordner mit dem Rubyskript `cd C:/DeinPfad/ZumSkript`
* Führe das Skript aus `ruby page_creator.rb`

# PDFs erstellen
Im Hauptordner folgenden Befehl ausführen:
    ruby page_creator.rb

# Neues Arbeitsblatt erstellen
Um einen neues Arbeitsblatt zu erstellen, muss
* Der Code in den Ordner `/karten/` abgelegt werden. Der Code muss die Endung `.lgo` haben und darf maximal 13 Zeilen umfassen.
* Ein Bild in den Ordner `/karten/muster` abgelegt werden. Das Bild muss als png gespeichert sein und die Endung `.png` haben.
* Das neue Arbeitsblatt in `config.yml` eingetragen werden. Mindestens muss das Label angegeben werden.

    -
      label: quadrat
      name: Schönes quadrat
      color: dfdfdf

label: gibt den Namen der Dateien an. Es ist wichtig, dass alle Dateien entsprechend beschriftet sind. In obigen Beispiel würde das heissen, dass `/karten/muster/quadrat.png` und `karten/muster/logo/quadrat.lgo` in existieren.
name (optional): gibt den Namen des Arbeitsblatt an. Falls dieser nicht angegeben wird, dann wird das Label mit Grosschreibung verwendet.
color (optional): gibt die Farbe des Arbeitsblattes als Hexadezimalzahl an.

# Probleme
Unter Windows beendet Inkscape nicht immer all Prozesse, die zum Erstellen der PDFs gestartet werden. Ich weiss noch nicht wieso. Im Moment müssen sie manuell im TaskManager gestoppt werden.

Die Keywordstabelle ist noch nicht komplett. Im Moment werden nur rt,lt,bk,fd,repeat,pd,pu,setpc als Schlüsselwörter erkannt.

Jegliche Zahlen werden als Argumente behandelt und entsprechend markiert.
