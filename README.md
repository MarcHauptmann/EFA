# EFA

Tools zur Verarbeitung von Fahrplandaten von [efa.de](http://efa.de). Im Moment wird nur der Großraum Hannover beachtet.

## Enthaltene Skripte

* **efa-departures** zur Anzeige der nächsten Abfahrten an einer Haltestelle
* **efa-station** zur Suche von Haltestellen

## Verwendung

Ein paar Beispiele

### Station suchen

    $ efa-stations Kröpcke
	Station               ID        
	--------------------------------
	Kröpcke               1000002256
	Kröpcke                 25000011
	Kröpckepassage               839
	Kröpcke/Theaterstraße   25000001

### Abfahrten einer Station anzeigen

Hat man mittels **efa-stations** die ID einer Station gefunden, so können die nächsten Abfahrten angezeigt werden.

	$ efa-departures -n 5 25000011
	Minuten Linie Ziel                        
	------------------------------------------
	0         5   Hannover Stöcken            
	0         2   Hannover Alte Heide         
	0         7   Hannover Schierholzstraße   
	0       100   Hannover August-Holweg-Platz
	1         5   Anderten
