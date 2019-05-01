#include<iostream>
#include<string>
#include<fstream>
#include<cstdlib>
#include<bitset>
#include<map>
#include<climits>

using namespace std;

int stringToInt(string str) //string to int converter
{
	int num=0;
	int size=str.size();
	for(int i = 0; i < str.size(); i++)
	{
    	num *= 10;
   		num += str[i]-'0';
	}
	return num;
}

int main(void)
{
	int type; //indicates single op, double op, branching, etc
	/*
	type 1 -- double operand ALU
	type 2 -- single operand ALU
	type 3 -- load
	type 4 -- branching
	type 5 -- halt or no operation
	type 6 -- fp set
	type 7 -- store
	*/
	
	//binary inputs
	string data;
	string instruction;
	string r1;
	string r2;
	string r3;
	
	int programCounter=-1; //instruction counter
	map<string, int> labels; //map for labels
	
	//binary outputs
	string opcode;
	string r1Register;
	string r2Register;
	string r3Register;
	string immediateBits;
	bool immediate=false; //immediate value indicator
	
	ifstream inFile;
	ofstream outFile;
	
	//opens the file
	inFile.open("Test.txt");
	outFile.open("output.txt");

	//makes sure that the file opened properly
	if(inFile.fail())
	{
		cout << "Input file opening failed." << endl;
		exit(1);
	}

	//extracts data from the file
	while (!inFile.eof())
	{
		start: getline(inFile, data);
		immediate=false; //reset immediate indicator
		instruction=data.substr(0,data.find(" ")); //finds and encodes the instruction
		string comment=data.substr(0,2);
		if(comment=="--") //ignores comments
			goto start;
		if(data.find(':') != string::npos) //looks for : for labels
    	{
    		string lab = data.substr(0, data.length()-1); //separates the label
    		labels[lab]=programCounter+1; //maps the label to the line number
    		goto start;		
		}
		else if(instruction=="Nop")
			{opcode="00000";type=5;}
		else if(instruction=="Set")
			{opcode="00001";type=6;}
		else if(instruction=="Load")
			{opcode="00010";type=3;}
		else if(instruction=="Store")
			{opcode="00011";type=7;}
		else if(instruction=="Move")
			{opcode="00100";type=2;}
		else if(instruction=="Fadd")
			{opcode="00101";type=1;}
		else if(instruction=="Fsub")
			{opcode="00110";type=1;}
		else if(instruction=="Fneg")
			{opcode="01011";type=2;}
		else if(instruction=="Fmul")
			{opcode="00111";type=1;}
		else if(instruction=="Fdiv")
			{opcode="01000";type=1;}
		else if(instruction=="Floor")
			{opcode="01100";type=2;}
		else if(instruction=="Ceil")
			{opcode="01101";type=2;}
		else if(instruction=="Round")
			{opcode="01110";type=2;}
		else if(instruction=="Fabs")
			{opcode="01111";type=2;}
		else if(instruction=="Min")
			{opcode="01001";type=1;}
		else if(instruction=="Max")
			{opcode="01010";type=1;}
		else if(instruction=="Pow")
			{opcode="10010";type=2;}
		else if(instruction=="Exp")
			{opcode="10000";type=2;}
		else if(instruction=="Sqrt")
			{opcode="10001";type=2;}
		else if(instruction=="B")
			{opcode="10011";type=4;}
		else if(instruction=="Bz")
			{opcode="10100";type=4;}
		else if(instruction=="Bn")
			{opcode="10101";type=4;}
		else if(instruction=="Halt")
			{opcode="10110";type=5;}
		programCounter++; //counting lines
		
		for(int i=0;i<data.length()-1;i++)
		{
			if(data[i]=='#')
				immediate=true;
		}
		
		switch(type) //fully encodes and outputs
		{
			case 1://double operand
				{
					int number2;
					int offset=0;
					string sub=data.substr(data.find("R")+1);
					if(sub[1]==',')
					{
						r1=sub[0];
					}
					else
					{
						r1=sub.substr(0,2);
						offset=1;
					}
					number2 = stringToInt(r1);
					bitset<4> r1(number2);
					
					sub=data.substr(data.find("R")+1);
					sub=sub.substr(4+offset);
					if(sub[1]==',')
						r2=sub[0];
					else
					{
						r2=sub.substr(0,2);
						offset=offset+1;
					}
					number2 = stringToInt(r2);
					bitset<4> r2(number2);
					
					sub=data.substr(data.find("R")+1);
					sub=sub.substr(8+offset);
					if(sub[1]==',')
						r3=sub[0];
					else
					{
						r3=sub.substr(0,2);
					}
					number2 = stringToInt(r3);
					bitset<4> r3(number2);
					
					cout<<opcode<<r1<<r2<<r3<<"000000000000000"<<endl;
					outFile<<opcode<<r1<<r2<<r3<<"000000000000000"<<endl;
				}
			break;
			case 2://single operand
				{
					int number2;
					int offset=0;
					string sub=data.substr(data.find("R")+1);
					if(sub[1]==',')
					{
						r1=sub[0];
					}
					else
					{
						r1=sub.substr(0,2);
						offset=1;
					}
					number2 = stringToInt(r1);
					bitset<4> r1(number2);
					
					sub=data.substr(data.find("R")+1);
					sub=sub.substr(4+offset);
					if(sub[1]==',')
						r2=sub[0];
					else
					{
						r2=sub.substr(0,2);
						offset=offset+1;
					}
					number2 = stringToInt(r2);
					bitset<4> r2(number2);
					
					cout<<opcode<<r1<<r2<<"0000000000000000000"<<endl;
					outFile<<opcode<<r1<<r2<<"0000000000000000000"<<endl;
				}
			break;
			case 3://load
				{
					int number2;
					int offset=0;
					string sub=data.substr(data.find("R")+1);
					if(sub[1]==',')
					{
						r1=sub[0];
					}
					else
					{
						r1=sub.substr(0,2);
						offset=1;
					}
					number2 = stringToInt(r1);
					bitset<4> r1(number2);
					
					sub=data.substr(data.find("R")+1);
					sub=sub.substr(4+offset);
					if(sub[1]==',')
						r2=sub[0];
					else
					{
						r2=sub.substr(0,2);
						offset=offset+1;
					}
					number2 = stringToInt(r2);
					bitset<4> r2(number2);
					
					cout<<opcode<<r1<<"0000"<<r2<<"000000000000000"<<endl;
					outFile<<opcode<<r1<<"0000"<<r2<<"000000000000000"<<endl;
				}
			break;
			case 7://store
				{
					int number2;
					int offset=0;
					string sub=data.substr(data.find("R")+1);
					if(sub[1]==',')
					{
						r1=sub[0];
					}
					else
					{
						r1=sub.substr(0,2);
						offset=1;
					}
					number2 = stringToInt(r1);
					bitset<4> r1(number2);
					
					sub=data.substr(data.find("R")+1);
					sub=sub.substr(4+offset);
					if(sub[1]==',')
						r2=sub[0];
					else
					{
						r2=sub.substr(0,2);
						offset=offset+1;
					}
					number2 = stringToInt(r2);
					bitset<4> r2(number2);
					
					cout<<opcode<<"0000"<<r2<<r1<<"000000000000000"<<endl;
					outFile<<opcode<<"0000"<<r2<<r1<<"000000000000000"<<endl;
				}
			break;
			case 4://branching
				{
					string sub=data.substr(data.find(" ")+1, data.length()-1); //takes away opcode from string
					string sub2=sub.substr(1, data.find(",")-4); //finds the register number
					int number2 = stringToInt(sub2);
					bitset<4> r1Register(number2); //binary converter of register
					string tin = sub.substr(sub.find("<")+1); //separates beginning of the label
					string bas = tin.substr(0, tin.length()-1); //cuts off the > from the label
				    if(instruction=="B")
				    {
				    	bitset<15> r2Register(labels[bas]); //binary converter of the label from table
				    	cout<<opcode<<"000000000000"<<r2Register<<endl;
				    	outFile<<opcode<<"000000000000"<<r2Register<<endl;
					}
					else
					{
						bitset<19> r2Register(labels[bas]); //binary converter of the label from table
						cout<<opcode<<"0000"<<r1Register<<r2Register<<endl;
				    	outFile<<opcode<<"0000"<<r1Register<<r2Register<<endl;	
					}
				}
			break;
			case 5: //halt or no operation
				{
					r1Register="0000";
					r2Register="0000";
					r3Register="0000";
					immediateBits="000000000000000";
				    cout<<opcode<<r1Register<<r2Register<<r3Register<<immediateBits<<endl;
				    outFile<<opcode<<r1Register<<r2Register<<r3Register<<immediateBits<<endl;
				}
			break;
			case 6: //fp set ***uses 2 lines, one for instruction, one for 32-bit fp number
				{
					r1=data.substr(data.find("#")+1,data.length()-1);
					int number2;
					string sub=data.substr(data.find("R")+1);
					if(sub[1]==',')
					{
						r2=sub[0];
					}
					else
					{
						r2=sub.substr(0,2);
					}
					number2 = stringToInt(r2);
					bitset<4> r2(number2);
					r2Register="0000";
					r3Register="0000";
					immediateBits="000000000000000";
				    cout<<opcode<<r2<<r2Register<<r3Register<<immediateBits<<endl;
				    outFile<<opcode<<r2<<r2Register<<r3Register<<immediateBits<<endl;
				    
					float number=atof(r1.c_str());
					union
  					{
        				float in;   // assumes sizeof(float) = sizeof(int)
        				int   out;
   					}data;

    				data.in = number;
					std::bitset<sizeof(float) * CHAR_BIT>   bits(data.out);
					cout<<bits<<endl;
					outFile<<bits<<endl;
				}
			break;
		}
		
		//fadd fsub fneg floor ceil round fabs min max
		//min max round
		//min - round to lowest integer (cut off decimals)
		//max - round to highest integer (cut off decimals and add 1)
		//round - (if decimal < .5 min, if decimal >= .5 max)
		
		//check power for immediate values
		
		
		cout<<data<<endl<<endl;
		//outFile<<data<<endl;
	}

	cin.ignore();
	outFile.close();
	inFile.close();
	
	return 0;
}
