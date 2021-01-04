if object_id('fgetStrPhoneNumber') is not null
begin
	drop function fgetStrPhoneNumber
end
go

create FUNCTION fgetStrPhoneNumber(@UserID int, @Separator varchar(5))
RETURNS varchar(max)
as
begin
    return
        (select
            (
                select
                    s.PhoneNumber  + @Separator
                from
                    (select
                        s1.ID as UserID,
                        s1.LoginMobile as PhoneNumber
                    from
                        [USER] s1
                    where s1.ID = a.UserID
                      and s1.UserType = 0
                      and s1.LoginMobile is not null

                    union

                    select
                        s2.UserID,
                        s2.PhoneNumber
                    from
                        PHONE s2
                    where s2.UserID = a.UserID
                      and s2.Available = 1) s
                for xml path(''))
        from
            CUSTOMER a
        where a.UserID = @UserID
        group by a.UserID)
end
