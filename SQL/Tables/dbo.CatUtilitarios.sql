CREATE TABLE [dbo].[CatUtilitarios]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[sUnidad] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dFecha] [datetime] NOT NULL,
[bActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CatUtilitarios] ADD CONSTRAINT [PK_CatUtilitarios] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
