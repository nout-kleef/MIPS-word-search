/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char *s, int size) { fgets(s, size, stdin); }
void print_char(int c) { putchar(c); }
void print_int(int i) { printf("%i", i); }
void print_string(char *s) { printf("%s", s); }
void output(char *string) { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */) * MAX_DIM_SIZE + 1 /* for \0 */];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */) + 1 /* for \0 */];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////

// starting indices for all dictionary entries
int dictionary_idx[MAX_DICTIONARY_WORDS];
// actual number of words in the dictionary
int dict_num_words = 0;
int grid_num_rows = 0;
int grid_num_cols = 0;

void print_word(char *word)
{
  while (*word != '\n' && *word != '\0')
  {
    print_char(*word);
    word++;
  }
}

void print_match(int row, int col, char *word, char direction)
{
  print_int(row);
  print_char(',');
  print_int(col);
  print_char(' ');
  print_char(direction);
  print_char(' ');
  print_word(word);
  print_char('\n');
}

int lastrow(char *string) // returns true if row == 0
{
  while (*string++ != '\n')
    ;
  return *string == '\0'; // true if final row
}

int contain_hor(char *string, char *word)
{
  while (1)
  {
    if (*string != *word)
      return *word == '\n';
    // characters are equal
    if (*string == '\n')
      return 1;
    string++; // 1 right, 0 down
    word++;
    // after this increment, we may have run into the following:
    //      X   X   \n
    //     [h] [i] [\n]
    //      X   X   \n
    // and if our word is "hi\n", we'll still have a match.
    if (*string == '\n')
      return *word == '\n';
  }
}

int contain_ver(char *string, char *word)
{
  while (1)
  {
    if (*string != *word)
      return *word == '\n';
    word++;
    if (lastrow(string))
      return *word == '\n';
    string += grid_num_cols + 1; // 0 right, 1 down
  }
}

int contain_dia(char *string, char *word)
{
  while (1)
  {
    if (*string != *word)
      return *word == '\n';
    word++;
    if (lastrow(string))
      return *word == '\n';
    string += grid_num_cols + 2; // 1 right, 1 down
    // after this increment, we may have run into the following:
    //     [h] X  \n
    //      X [i] \n
    //      X  X [\n]
    // and if our word is "hi\n", we'll still have a match.
    if (*string == '\n')
      return *word == '\n';
  }
}

void strfind()
{
  int wordfound = 0;
  int idx = 0;
  int grid_idx = 0;
  int xcoord = 0;
  int ycoord = 0;
  char *word;
  // for each row
  while (grid[grid_idx] != '\0')
  {
    while (grid[grid_idx] != '\n')
    {
      // no need to check for '\0', grid files are terminated by '\n',
      // so we will definitely break out of this loop.
      for (idx = 0; idx < dict_num_words; idx++)
      {
        word = dictionary + dictionary_idx[idx]; // point to dict entry
        if (contain_hor(grid + grid_idx, word))
        {
          print_match(ycoord, xcoord, word, 'H');
          wordfound = 1; // flag that we've found a word
        }
        if (contain_ver(grid + grid_idx, word))
        {
          print_match(ycoord, xcoord, word, 'V');
          wordfound = 1; // flag that we've found a word
        }
        if (contain_dia(grid + grid_idx, word))
        {
          print_match(ycoord, xcoord, word, 'D');
          wordfound = 1; // flag that we've found a word
        }
      }
      grid_idx++;
      xcoord++;
    }
    grid_idx++; // skip over '\n'
    xcoord = 0;
    ycoord++;
  }
  if (wordfound)
    return; // skip over printing "-1"
  print_string("-1\n");
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main(void)
{

  int dict_idx = 0;
  int start_idx = 0;

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if (grid_file == NULL)
  {
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if (dictionary_file == NULL)
  {
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do
  {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if (feof(grid_file))
    {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;

  // reading the dictionary file
  do
  {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if (feof(dictionary_file))
    {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////

  // compute the actual dimensions of the grid
  char *c = grid;
  grid_num_rows = 0;
  while (*c != '\0')
  {
    grid_num_cols = 0;
    grid_num_rows++;
    while (*c != '\n')
    {
      c++;
      grid_num_cols++;
    }
    c++; // pass over '\n'
  }

  idx = 0;
  do
  {
    c_input = dictionary[idx];
    if (c_input == '\0')
    {
      break;
    }
    if (c_input == '\n')
    {
      dictionary_idx[dict_idx++] = start_idx;
      start_idx = idx + 1;
    }
    idx += 1;
  } while (1);

  dict_num_words = dict_idx;

  strfind();

  return 0;
}
