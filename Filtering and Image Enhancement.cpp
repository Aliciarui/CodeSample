// ******************************
// Code Sample(C++)
// Filtering and Image Enhancement
// Qi Rui
// ******************************
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<malloc.h>
#include<math.h> 
 
typedef unsigned short UINT16;
typedef unsigned long DWORD;
typedef unsigned char UNCHAR;

#pragma pack(1)
typedef struct tagBITMAPFILEHEADER
{
	UNCHAR byType[2];
	DWORD  bfSize;
	UINT16 bfReserved1;
	UINT16 bfReserved2;
	DWORD bfOffBits;
}FileHeader;
#pragma pack()

#pragma pack(1)
typedef struct tagBITMAPINFOHEADER{
	DWORD biSize;
	DWORD biWidth;
 	DWORD biHeight;
	UINT16 biPlanes;
	UINT16 biBitCount;
	DWORD biCompression;
	DWORD biSizeImage;
	DWORD biXPelsPerMeter;
	DWORD biYPelsPerMeter;
	DWORD biClrUsed;
	DWORD biClrImportant;
}InfoHeader;
#pragma pack()

#pragma pack(1) 
typedef struct RGBIMG{
	UNCHAR **b;
	UNCHAR **g;
	UNCHAR **r;
}rgbIMG,*rgbimgINFO;
#pragma pack()

#pragma pack(1) 
typedef struct YUVIMG{
	UNCHAR **y;
	UNCHAR **u;
	UNCHAR **v;
}yuvIMG,*yuvimgINFO;
#pragma pack()

#pragma pack(1) 
typedef struct RGBQUAD{
	UNCHAR rgbBlue;
	UNCHAR rgbGreen;
	UNCHAR rgbRed;
	UNCHAR rgbReserved;
};
#pragma pack()


/*
	Function: Extracting RGB information from bmp images
	Input: Header, Infoheader, fp
	Return: RGB structure
*/
rgbimgINFO bmpstruct(FileHeader* header,InfoHeader* infoheader,FILE* fp)
{ 
	rgbimgINFO imageinfo=(rgbimgINFO)malloc(sizeof(rgbIMG));
	if(!imageinfo){
		printf("fail to malloc rgb");
		return NULL;
	}
	
	fseek(fp,header->bfOffBits,SEEK_SET);
	int width=infoheader->biWidth;
	int height=infoheader->biHeight;
	
	int row,col;
	imageinfo->b=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		imageinfo->b[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
		
	imageinfo->g=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		imageinfo->g[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
		
	imageinfo->r=(UNCHAR **)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		imageinfo->r[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
	
	for(row=0;row<height;row++){
		for(col=0;col<width;col++){
			fread(&imageinfo->b[row][col],sizeof(UNCHAR),1,fp);
			fread(&imageinfo->g[row][col],sizeof(UNCHAR),1,fp);
			fread(&imageinfo->r[row][col],sizeof(UNCHAR),1,fp);
		}
	}
	return imageinfo;
}

/*
	Function: Converting RGB information to YUV information 
	Input: Header, Infoheader, fp
	Return: YUV structure
*/
yuvimgINFO yuvstruct(rgbimgINFO rgb,int height,int width)
{
	yuvimgINFO yuv=(yuvimgINFO)malloc(sizeof(yuvIMG));
	if(!yuv){
		printf("fail to malloc yuv");
		return NULL;
	}
	
	int row,col;
	
	yuv->y=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		yuv->y[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
	
	yuv->u=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		yuv->u[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
	
	yuv->v=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		yuv->v[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}	
	
	for(row=0;row<height;row++){
		for(col=0;col<width;col++){
			yuv->y[row][col]=UNCHAR(0.299*rgb->r[row][col]+0.587*rgb->g[row][col]+0.144*rgb->b[row][col]);
			yuv->u[row][col]=UNCHAR(-0.147*rgb->r[row][col]-0.289*rgb->g[row][col]+0.436*rgb->b[row][col]);
			yuv->v[row][col]=UNCHAR(0.615*rgb->r[row][col]-0.515*rgb->g[row][col]-0.100*rgb->b[row][col]);						
		}
	}
	return yuv;		
}

/*
	Function: Converting YUV information to RGB information
	Input: Header, Infoheader, fp
	Return: RGB structure
*/
rgbimgINFO rgbstruct(yuvimgINFO yuv,int height,int width)
{
	rgbimgINFO rgb=(rgbimgINFO)malloc(sizeof(rgbIMG));
	if(!rgb){
		printf("fail to malloc rgb");
		return NULL;
	}
	
	int row,col;
	
	
	rgb->b=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		rgb->b[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}	
	rgb->g=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		rgb->g[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}	
	rgb->r=(UNCHAR **)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		rgb->r[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
	
	for(row=0;row<height;row++){
		for(col=0;col<width;col++){
			rgb->r[row][col]=UNCHAR(1.0000*yuv->y[row][col]+1.1398*yuv->v[row][col]);
			rgb->g[row][col]=UNCHAR(0.9996*yuv->y[row][col]-0.3954*yuv->u[row][col]-0.5805*yuv->v[row][col]);
			rgb->b[row][col]=UNCHAR(1.0020*yuv->y[row][col]+2.0361*yuv->u[row][col]-0.0005*yuv->v[row][col]);						
		}
	}
	return rgb;		
}

/*
	Function: Rearrange the grayscale image and calculate the maximum and minimum values of the two-dimensional matrix
	Input: Row and column values, original two-dimensional array matrix
	Return: Rearranged array matrix
*/
UNCHAR **rearrange(UNCHAR **arran,int row,int col){
	int i,j;
	UNCHAR max=0,min=0;
	UNCHAR interval;
	UNCHAR **rearran=(UNCHAR**)malloc(sizeof(UNCHAR*)*row);
	for(i=0;i<row;i++){
		rearran[i]=(UNCHAR*)malloc(sizeof(UNCHAR)*col);
	}
	for(i=0;i<row;i++){
		for(j=0;j<col;j++){
			if(arran[i][j]>max){
				max=arran[i][j];
			}
		}
	}
	for(i=0;i<row;i++){
		for(j=0;j<col;j++){
			if(arran[i][j]<min){
				min=arran[i][j];
			}
		}
	}
	interval=max-min;
	for(i=0;i<row;i++){
		for(j=0;j<col;j++){
			rearran[i][j]=UNCHAR(255*(arran[i][j]-min)/interval);
		}
	}
	return rearran;
}


/*
	Function: Laplacian
	Input: Row and column values, original two-dimensional array matrix
	Return: Array matrix after laplacian
*/
UNCHAR **laplacian(UNCHAR **original,int row,int col){
	int i,j;
	int x,y;
	int a;
	UNCHAR **lapla=(UNCHAR**)malloc(sizeof(UNCHAR*)*row);
	for(i=0;i<row;i++){
		lapla[i]=(UNCHAR*)malloc(sizeof(UNCHAR)*col);
	}
	
	for(i=0;i<row;i++){
		for(j=0;j<col;j++){
			lapla[i][j]=0;
		}
	}
	
	for(i=1;i<row-1;i++){
		for(j=1;j<col-1;j++){
			a=4*original[i][j]-(original[i-1][j]+original[i][j-1]+original[i][j+1]+original[i+1][j]);
			if(a>255) a=255;
			else if(a<0) a=0;
			lapla[i][j]=a;
		}
	}
	for(i=0;i<row;i++){
		lapla[i][0]=original[i][0];
		lapla[i][col-1]=original[i][col-1];
	}
	for(i=1;i<col-1;i++){
		lapla[0][i]=original[0][i];
		lapla[row-1][i]=original[row-1][i];
	} 
	
	for(i=0;i<row;i++){
		for(j=0;j<col;j++){
			if(lapla[i][j]>0) a=original[i][j]+lapla[i][j];
			else a=original[i][j]-lapla[i][j];
			if(a>255) a=255;
			else if(a<0) a=0;
			original[i][j]=a;
		}
	}
	
	return original;
} 


int main(){
	FILE *fpbmp;
	FILE *fpgray,*fpcolor;
	FILE *fplaplacian;
	FileHeader bmpfileheader;
	InfoHeader bmpinfoheader;
	rgbimgINFO rgbpointer;
	yuvimgINFO yuvpointer;
	rgbimgINFO newrgbpointer;
	int row,col;
	int angle;

	fpbmp=fopen("lena.bmp","rb");
	if(!fpbmp){
		printf("Fail to open!");
		return 0;
	} 
	fseek(fpbmp,0,SEEK_SET);
	
	fread(&bmpfileheader,sizeof(FileHeader),1,fpbmp);
	fread(&bmpinfoheader,sizeof(InfoHeader),1,fpbmp);
	int width;
	int height;	
	if(bmpinfoheader.biBitCount>=24){
		rgbpointer=bmpstruct(&bmpfileheader,&bmpinfoheader,fpbmp);
		width=bmpinfoheader.biWidth;
		height=bmpinfoheader.biHeight;
	}
	
 	yuvpointer=yuvstruct(rgbpointer,height,width);
 	UNCHAR**newvalueY=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		newvalueY[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
 	newvalueY=rearrange(yuvpointer->y,height,width);
 	
	fpgray=fopen("graylena.bmp","wb");
	if(!fpgray){
		printf("Fail to open!");
	}
	else{
		fwrite(&bmpfileheader,sizeof(FileHeader),1,fpgray);
		fwrite(&bmpinfoheader,sizeof(InfoHeader),1,fpgray);
		
		for(row=0;row<height;row++){
			for(col=0;col<width;col++){
				fwrite(*(newvalueY+row)+col,sizeof(UNCHAR),1,fpgray);
				fwrite(*(newvalueY+row)+col,sizeof(UNCHAR),1,fpgray);
				fwrite(*(newvalueY+row)+col,sizeof(UNCHAR),1,fpgray);
			}
		}
		fclose(fpgray);
	}
	
	
	UNCHAR**newvalue=(UNCHAR**)malloc(sizeof(UNCHAR*)*height);
	for(row=0;row<height;row++){
		newvalue[row]=(UNCHAR*)malloc(sizeof(UNCHAR)*width);
	}
	newvalue=laplacian(newvalueY,height,width);
	fplaplacian=fopen("laplalena.bmp","wb");
	if(!fplaplacian){
		printf("Fail to open!");
	}
	else{
		fwrite(&bmpfileheader,sizeof(FileHeader),1,fplaplacian);
		fwrite(&bmpinfoheader,sizeof(InfoHeader),1,fplaplacian);
		
		for(row=0;row<height;row++){
			for(col=0;col<width;col++){
				fwrite(*(newvalue+row)+col,sizeof(UNCHAR),1,fplaplacian);
				fwrite(*(newvalue+row)+col,sizeof(UNCHAR),1,fplaplacian);
				fwrite(*(newvalue+row)+col,sizeof(UNCHAR),1,fplaplacian);
			}
		}
		fclose(fplaplacian);
	}
	
	
	newrgbpointer=rgbstruct(yuvpointer,height,width);
	
	newrgbpointer->r=laplacian(rgbpointer->r,height,width);
	newrgbpointer->g=laplacian(rgbpointer->g,height,width);
	newrgbpointer->b=laplacian(rgbpointer->b,height,width); 
	
	fpcolor=fopen("colorlena2.bmp","wb");
	if(!fpcolor){
		printf("Fail to open!\n");
	} 
	
	fwrite(&bmpfileheader,sizeof(FileHeader),1,fpcolor);
	fwrite(&bmpinfoheader,sizeof(InfoHeader),1,fpcolor);	
	for(row=0;row<height;row++){
		for(col=0;col<width;col++){
			fwrite(*(newrgbpointer->b+row)+col,sizeof(UNCHAR),1,fpcolor);
			fwrite(*(newrgbpointer->g+row)+col,sizeof(UNCHAR),1,fpcolor);
			fwrite(*(newrgbpointer->r+row)+col,sizeof(UNCHAR),1,fpcolor);
		}
	}
	fclose(fpcolor); 
	system("pause"); 
	return 0;
}
