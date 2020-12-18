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
		'��ʾְλ',
		1,
		'Title_Show',
		'|1|',
		15,
		8.1,
		'�����Ƿ���ʾְλ',
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
		'��ʾ����',
		1,
		'Name_Show',
		'|1|',
		15,8.2,
		'�����Ƿ���ʾ����',
		'');
--49��ʾְλ��50��ʾ����
select * from SYS_JURISDICTION;