# EFA

Tools zur Verarbeitung von Fahrplandaten von [efa.de](http://efa.de). Im Moment wird nur der Großraum Hannover beachtet.

## Enthaltene Skripte

* **efa-departures** zur Anzeige der nächsten Abfahrten an einer Haltestelle
* **efa-station** zur Suche von Haltestellen

## Verwendung

Ein paar Beispiele

### Station suchen

    $ efa-station Kröpcke
	Station               ID        
	--------------------------------
	Kröpcke               1000002256
	Kröpcke                 25000011
	Kröpckepassage               839
	Kröpcke/Theaterstraße   25000001

### Abfahrten einer Station anzeigen

Hat man mittels **efa-stations** die ID einer Station gefunden, so können die nächsten Abfahrten angezeigt werden.

	$ efa-departures -n 5 25000011
	Minuten Haltestelle Typ       Linie Ziel                     
	-------------------------------------------------------------
	0       Kröpcke     Stadtbahn 5     Anderten                 
	0       Kröpcke     Stadtbahn 2     Rethen                   
	0       Kröpcke     Stadtbahn 7     Hannover Wettbergen      
	1       Kröpcke     Stadtbahn 6     Hannover Nordhafen       
	1       Kröpcke     Stadtbahn 8     Hannover Hauptbahnhof (U)
