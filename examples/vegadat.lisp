;; from https://github.com/Lisp-Stat/plot/blob/master/src/vega/vega-datasets.lisp
(defpackage :examples/vegadat
  (:use :cl :std :net/fetch :dat)
  (:export 
   :*vega-datasets* :*vega-dataset-base-url*
   :fetch-vega-dataset))

(in-package :examples/vegadat)

(defparameter *vega-dataset-base-url* "http://raw.githubusercontent.com/vega/vega-datasets/main/data/"
  "Base URL for datasets included in Vega")

(defparameter *vega-dataset-stash* "vega/")


;; (gethash :airpots *vega-datasets*)
(defvar *vega-datasets* (make-hash-table :size 66 :test #'equal)
  "All Vega example data sets. k=symbol,v=url")

(defun push-dataset (key)
  "Push a dataset to *VEGA-DATASETS* by filename."
  (let ((val (concatenate 'string *vega-dataset-base-url* key)))
    (setf (gethash key *vega-datasets*) val)))

;; 66 files total, mostly json and csv. 1 tsv file, 1 arrow file.
(mapc #'push-dataset
      '("airports.csv" "annual-precip.json" "anscombe.json" "barley.json" "budget.json" "budgets.json" "burtin.json" "cars.json" "countries.json" "crimea.json" "driving.json" "earthquakes.json" "flare-dependencies.json" "flare.json" "flights-10k.json" "flights-200k.json" "flights-20k.json" "flights-2k.json" "flights-5k.json" "football.json" "gapminder.json" "income.json" "jobs.json" "londonBoroughs.json" "londonCentroids.json" "londonTubeLines.json" "miserables.json" "monarchs.json" "movies.json" "normal-2d.json" "obesity.json" "ohlc.json" "penguins.json" "points.json" "political-contributions.json" "population.json" "udistrict.json" "unemployment-across-industries.json" "uniform-2d.json" "us-10m.json" "us-state-capitals.json" "volcano.json" "weather.json" "wheat.json" "world-110m.json" "airports.csv" "birdstrikes.csv" "co2-concentration.csv" "disasters.csv" "flights-3m.csv" "flights-airport.csv" "gapminder-health-income.csv" "github.csv" "iowa-electricity.csv" "la-riots.csv" "lookup_groups.csv" "lookup_people.csv" "population_engineers_hurricanes.csv" "seattle-weather-hourly-normals.csv" "seattle-weather.csv" "sp500-2000.csv" "sp500.csv" "stocks.csv" "us-employment.csv" "weather.csv" "windvectors.csv" "zipcodes.csv" "unemployment.tsv" "flights-200k.arrow"))

(defun fetch-vega-datasets ()
  (ensure-directories-exist *vega-dataset-stash*)
  (maphash-keys
   (lambda (x) (download (gethash x *vega-datasets*) 
                         (merge-pathnames x *vega-dataset-stash*)))
   *vega-datasets*))

(defun purge-vega-datasets ()
  (std:when-let ((stash (probe-file *vega-dataset-stash*)))
    (sb-ext:delete-directory stash :recursive t)))
