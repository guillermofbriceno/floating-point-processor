#include<iostream>
#include<string>
#include<fstream>
#include<cstdlib>

using namespace std;

int main(void)
{
	string data;
	
	ifstream inFile;
	string fileLocation = "Test.txt";
	
	//opens the file
	inFile.open("Test.txt");

	//makes sure that the file opened properly
	if(inFile.fail())
	{
		cout << "Input file opening failed." << endl;
		exit(1);
	}

	//extracts data from the file
	while (!inFile.eof())
	{
		getline(inFile, data);
		cout <<data<<endl;
	}

	cin.ignore();
	
	inFile.close();
	
	return 0;
}
