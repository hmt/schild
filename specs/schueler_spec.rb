require "#{File.dirname(__FILE__)}/spec_helper"

describe Schueler do
  before do
    # lade einen Standardschueler
    @sm = Schueler.where(:Status => 2, :Geloescht => "-", :Gesperrt => "-").first
  end

  describe 'Models funktionieren erwartungsgemäß und geben einen Wert aus der Tabelle zurück' do
    it 'Model gibt Vornamen zurück' do
      @sm.Vorname.must_equal "Tanja"
    end
  end

  describe 'Associations funktionieren Erwartungsgemäß' do
    it 'geben Fachklassenbezeichnung zurück (eigeneschule_fachklassen:Fachklassen)' do
      @sm.fachklasse.Bezeichnung.must_equal "Friseur"
    end

    it 'geben Noten aus dem angegebenen Halbjahr und Jahr zurück (via Lernabschnitte und Leistungen)' do
      @sm.erstes_halbjahr(2013).noten.first.ID.must_equal 163701
    end

    it 'gibt Konferenzdatum zurück (Lernabschnitte)' do
      skip
      # offenbar keine in der Testdatenbank eingetragen
      @sm.erstes_halbjahr(2013)[:Konferenzdatum].must_be_instance_of Date
    end

    it 'gibt berufsbezogene Fächer aus den angegebenen Lernabschnitten zurück' do
      @sm.zweites_halbjahr(2013).berufsbezogen.map{|n|n.fach.FachKrz}.must_include 'FF'
    end

    it 'gibt berufsübergreifende Fächer aus den angegebenen Lernabschnitten zurück' do
      @sm.zweites_halbjahr(2013).berufsuebergreifend.map{|n|n.fach.FachKrz}.must_include 'D'
    end

    it 'gibt Fächer aus dem Differenzierungsbereich zurück über angegebenen Lernabschnitt' do
      skip
      @sm.erstes_halbjahr(2014).differenzierungsbereich.map{|n|n.fach.FachKrz}.must_include 'FF'
    end

    it 'gibt Fächer aus allen Fächergruppen zurück' do
      fg = @sm.zweites_halbjahr(2013).faechergruppen.flatten.count
      fg.must_equal (@sm.zweites_halbjahr(2013).noten.select{|n|!n.NotenKrz.nil?}).count
    end
  end

  describe 'gibt die korrekte Anzahl von Schülern über Klasse zurück' do
    it 'returns a group of people eg Klasse xy' do
      Schueler.where(:Klasse => 'FOS2').count.must_equal 124
    end
  end

  describe 'Methoden funktionieren erwartungsgemäß' do
    it 'returns the correct salutation' do
      @sm.anrede.must_equal "Frau"
    end

    it 'gibt an, ob ein Schüler volljährig ist' do
      @sm.volljaehrig?.must_equal true
    end

    it 'gibt ein zusammengesetztes Datum des Schuljahres zurück' do
      @sm.schuljahr.must_equal "2014/15"
    end

    it 'gibt die Textbezeichnung für eine Note zurück' do
      @sm.zweites_halbjahr(2013).noten[5].note.must_equal "gut"
    end

    it 'gibt die volle Fachbezeichnung zurück' do
      @sm.zweites_halbjahr(2013).noten[5].bezeichnung.must_equal "Farb- und Formveränderung"
    end

    it 'gibt die korrekte Fachgruppen_ID zurück' do
      @sm.zweites_halbjahr(2013).noten[5].fachgruppe_ID.must_equal 20
    end

    it 'gibt den Namen des Klassenlehrers zurück' do
      @sm.zweites_halbjahr(2013).v_name_klassenlehrer.must_equal "P. Ronnewinkel"
    end

    it 'gibt an, ob Klassenlehrer/in' do
      @sm.zweites_halbjahr(2013).klassenlehrer_in.must_equal "Klassenlehrer"
    end

    it 'gibt das zweite Halbjahr zurück' do
      @sm.zweites_halbjahr(2013).Abschnitt.must_equal 2
      @sm.zweites_halbjahr(2013).Jahr.must_equal 2013
    end

    it 'gibt das erste Halbjahr zurück' do
      @sm.erstes_halbjahr(2014).Abschnitt.must_equal 1
      @sm.erstes_halbjahr(2014).Jahr.must_equal 2014
    end

    it 'gibt das aktuelle Halbjahr zurück' do
      @sm.akt_halbjahr.Jahr.must_equal 2014
      @sm.akt_halbjahr.Abschnitt.must_equal 1
    end

    it 'wählt das angegebene Jahr und Halbjahr aus' do
      @sm.halbjahr(2013, 2).ID.must_equal 14478
    end
  end
end
