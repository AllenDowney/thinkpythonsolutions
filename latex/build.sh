#!/bin/bash
# Build the LaTex book version

# copy the python modules
rsync -a ../soln/thinkpython.py .
rsync -a ../soln/diagram.py .
rsync -a ../soln/structshape.py .

for NOTEBOOK in $@
do
    # remove image files generated by previous runs
    FIGS=${NOTEBOOK%.ipynb}_files
    echo "rm -f $FIGS/*"
    rm -f $FIGS/*

    # copy the notebook
    echo "cp ../soln/$NOTEBOOK ."
    cp ../soln/$NOTEBOOK .

    # add the header that generates LaTeX tables
    echo "python add_header.py header_latex.ipynb $NOTEBOOK"
    python add_header.py header_latex.ipynb $NOTEBOOK

    # run pytest to execute and overwrite the notebook
    # pytest --nbmake --overwrite $NOTEBOOK

    # use nbconvert to execute and overwrite the notebook
    echo "jupyter nbconvert --to markdown $NOTEBOOK"
    jupyter nbconvert --to notebook --execute $NOTEBOOK

    # remove cells with solutions
    echo "python remove_soln.py $NOTEBOOK"
    python remove_soln.py $NOTEBOOK

    # remove cells with remove-cell tag
    # (actually remove just the source and outputs)
    # We have to keep the cell;
    # otherwise it throws off the figure numbering
    echo "python remove_cells.py $NOTEBOOK"
    python remove_cells.py $NOTEBOOK

    # convert notebooks to markdown
    echo "jupyter nbconvert --to markdown $NOTEBOOK"
    jupyter nbconvert --to markdown $NOTEBOOK

    # convert markdown to LaTeX
    FLAGS="--listings --top-level-division=chapter"
    MDFILE=${NOTEBOOK%.ipynb}.md
    TEXFILE=${NOTEBOOK%.ipynb}.tex
    echo "pandoc $FLAGS -s $MDFILE -o $TEXFILE"
    pandoc $FLAGS -s $MDFILE -o $TEXFILE

    # remove front and backmatter from the chapters
    # (and make a few text substitutions)
    echo "python split.py $TEXFILE"
    python split.py $TEXFILE
done