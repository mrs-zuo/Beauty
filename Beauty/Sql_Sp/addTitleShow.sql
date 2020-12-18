declare @MaxId int
set @MaxId = (select max(id) from SYS_JURISDICTION);
insert into 
	SYS_JURISDICTION (
		ID,
		JurisdictionName,
		Available,
		PermissionName,
		[Type],
		ParentID,
		[Group],
		Describe,
		Advanced) 
	values(
		@MaxId+1,
		'显示职位',
		1,
		'Title_Show',
		'|1|',
		15,
		8.1,
		'设置是否显示职位',
		'');
insert into 
	SYS_JURISDICTION (
		ID,
		JurisdictionName,
		Available,
		PermissionName,
		[Type],
		ParentID,
		[Group],
		Describe,
		Advanced) 
	values(
		@MaxId+2,
		'显示名字',
		1,
		'Name_Show',
		'|1|',
		15,8.2,
		'设置是否显示名字',
		'');
--49显示职位，50显示名字
select * from SYS_JURISDICTION;