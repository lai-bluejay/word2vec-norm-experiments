include filenames.sh
source_corpus_url="http://lateral-datadumps.s3-website-eu-west-1.amazonaws.com/wikipedia_utf8_filtered_20pageviews.csv.gz"
word2vec_binary="word2vec/word2vec"
CC=gcc
CFLAGS=-lm -pthread -O3 -march=native -Wall -funroll-loops -Wno-unused-result

all: $(vectors_binary)

$(corpus_unmodified):
	wget -qO- $(source_corpus_url) | gunzip -c | python clean_corpus.py > $(corpus_unmodified)
$(word_counts): $(corpus_unmodified)
	cat $(corpus_unmodified) | python count_words.py > $(word_counts)	
$(word_freq_experiment_words) $(coocc_noise_experiment_words): $(word_counts)
	python choose_experiment_words.py
$(corpus_modified): $(corpus_unmodified) $(word_counts) $(word_freq_experiment_words) $(coocc_noise_experiment_words)
	python modify_corpus.py
$(word_counts_modified_corpus): $(corpus_modified)
	cat $(corpus_modified) | python count_words.py > $(word_counts_modified_corpus)	
$(word2vec_binary): word2vec/word2vec.c
	$(CC) word2vec/word2vec.c -o $(word2vec_binary) $(CFLAGS)
$(vectors_binary): $(word2vec_binary) $(corpus_modified)
	$(word2vec_binary) -min-count 200 -hs 0 -negative 5 -window 10 -size 100 -cbow 1 -debug 2 -threads 16 -iter 10 -binary 1 -output $(vectors_binary) -train $(corpus_modified)

.PHONY: clean images
images: $(vectors_binary) $(word_counts_modified_corpus)
	python build_images.py
clean:
	rm -rf $(word2vec_binary)
	rm $(corpus_modified)
	rm $(vectors_binary)
